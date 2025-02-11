# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class ProtocolSpec < View
        PROTOCOL_TEST_TRAITS = %w[smithy.test#httpRequestTests smithy.test#httpResponseTests].freeze

        def initialize(plan)
          @plan = plan
          @model = plan.model
          @all_operation_tests = Model::ServiceIndex
                                 .new(@model)
                                 .operations_for(@plan.service)
                                 .select { |_id, o| protocol_tests?(o) }
                                 .map { |id, o| OperationTests.new(@model, id, o) }
          super()
        end

        attr_reader :all_operation_tests

        def module_name
          @plan.module_name
        end

        def additional_requires
          Set.new(@all_operation_tests.map(&:additional_requires).flatten)
        end

        private

        def protocol_tests?(operation)
          !!operation.fetch('traits', {}).keys.intersect?(PROTOCOL_TEST_TRAITS)
        end

        # @api private
        class OperationTests
          def initialize(model, id, operation)
            @id = id
            @operation = operation
            # TODO: Should we filter protocol tests further by default protocol?
            # All cases currently have only a single protocol
            @request_tests = @operation
                             .fetch('traits', {})
                             .fetch('smithy.test#httpRequestTests', [])
                             .select { |t| t['appliesTo'] == 'client' }
                             .map { |t| RequestTest.new(model, operation, t) }
            @response_tests = @operation
                              .fetch('traits', {})
                              .fetch('smithy.test#httpResponseTests', [])
                              .select { |t| t['appliesTo'] == 'client' }
                              .map { |t| ResponseTest.new(model, operation, t) }

            # TODO: Handle Error test cases
          end

          attr_reader :request_tests, :response_tests

          def name
            Model::Shape.name(@id).underscore
          end

          def additional_requires
            @request_tests.map(&:additional_requires) + @response_tests.map(&:additional_requires)
          end
        end

        # @api private
        class TestCase
          def initialize(model, operation, test_case)
            @model = model
            @operation = operation
            @test_case = test_case
            @input_shape = Model.shape(@model, @operation['input']['target'])
            @output_shape = Model.shape(@model, @operation['output']['target'])
          end

          attr_reader :test_case

          def [](key)
            test_case[key]
          end

          def comments
            if test_case['documentation']
              test_case['documentation'].split("\n")
            else
              []
            end
          end

          def id
            test_case['id']
          end

          def params
            ShapeToHash.transform_value(@model, test_case.fetch('params', {}), @input_shape)
          end

          def additional_requires
            requires = []
            if test_case['bodyMediaType']
              requires +=
                case test_case['bodyMediaType']
                when 'application/cbor'
                  ['base64', 'smithy-client/cbor/value_matcher']
                end
            end
            requires << 'cgi' if query_expect?
            requires
          end
        end

        # @api private
        class RequestTest < TestCase
          def body_expect
            return nil unless test_case['body']

            case test_case['bodyMediaType']
            when 'application/cbor'
              'expect(Smithy::Client::CBOR.decode(request.body.read)).' \
              "to match_cbor(Smithy::Client::CBOR.decode(::Base64.decode64('#{test_case['body']}')))"
            else
              "expect(request.body.read).to eq('#{test_case['body']}')"
            end
          end

          def query_expect?
            test_case['queryParams'] || test_case['forbidQueryParams'] || test_case['requireQueryParams']
          end

          def idempotency_token_trait?
            @input_shape.fetch('members', {})
                        .any? { |_name, shape| shape.fetch('traits', {}).key?('smithy.api#idempotencyToken') }
          end
        end

        # @api private
        class ResponseTest < TestCase
        end
      end
    end
  end
end
