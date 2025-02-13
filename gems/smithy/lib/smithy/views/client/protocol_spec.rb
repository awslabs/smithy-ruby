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
          !!operation.fetch('traits', {}).keys.intersect?(PROTOCOL_TEST_TRAITS) || error_tests?(operation)
        end

        def error_tests?(operation)
          operation.fetch('errors', []).any? do |e|
            Model.shape(@model, e['target'])
                 .fetch('traits', {})
                 .key?('smithy.test#httpResponseTests')
          end
        end

        # @api private
        class OperationTests
          def initialize(model, id, operation)
            @model = model
            @id = id
            @operation = operation
            # TODO: Should we filter protocol tests further by default protocol?
            # All cases currently have only a single protocol
            @request_tests = build_request_tests
            @response_tests = build_response_tests
            @error_tests = build_error_tests
          end

          attr_reader :request_tests, :response_tests, :error_tests

          def name
            Model::Shape.name(@id).underscore
          end

          def additional_requires
            @request_tests.map(&:additional_requires) + @response_tests.map(&:additional_requires)
          end

          private

          def build_response_tests
            @operation
              .fetch('traits', {})
              .fetch('smithy.test#httpResponseTests', [])
              .select { |t| t['appliesTo'] == 'client' }
              .map { |t| ResponseTest.new(@model, @operation, t) }
          end

          def build_request_tests
            @operation
              .fetch('traits', {})
              .fetch('smithy.test#httpRequestTests', [])
              .select { |t| t['appliesTo'] == 'client' }
              .map { |t| RequestTest.new(@model, @operation, t) }
          end

          def build_error_tests
            @operation
              .fetch('errors', [])
              .map { |e| tests_for_error(e) }
              .flatten
          end

          def tests_for_error(error)
            error_shape = Model.shape(@model, error['target'])
            # NOTE: error tests do not have a appliesTo that should be checked
            error_shape
              .fetch('traits', {})
              .fetch('smithy.test#httpResponseTests', [])
              .map { |t| ErrorTest.new(@model, @operation, error['target'], t) }
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

          def additional_requires
            requires = []
            if test_case['bodyMediaType']
              requires +=
                case test_case['bodyMediaType']
                when 'application/cbor'
                  ['base64', 'smithy-client/cbor/value_matcher']
                end
            end
            requires
          end
        end

        # @api private
        class RequestTest < TestCase
          def params
            ShapeToHash.transform_value(@model, test_case.fetch('params', {}), @input_shape)
          end

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
          def params
            ShapeToHash.transform_value(@model, test_case.fetch('params', {}), @output_shape)
          end

          def stub_body
            case test_case['bodyMediaType']
            when 'application/cbor'
              "::Base64.decode64('#{test_case['body']}')"
            else
              "'#{test_case['body']}'"
            end
          end

          def data_expect
            case test_case['bodyMediaType']
            when 'application/cbor'
              "expect(resp.data.to_h).to match_cbor(#{params})"
            else
              "expect(resp.data.to_h).to eq(#{params})"
            end
          end

          def streaming_member
            @output_shape
              .fetch('members', {})
              .map { |name, member| [name, Model.shape(@model, member['target'])] }
              .find { |_name, shape| shape.fetch('traits', {}).key?('smithy.api#streaming') }
          end
        end

        # @api private
        class ErrorTest < ResponseTest
          def initialize(model, operation, error_id, test_case)
            super(model, operation, test_case)
            @error_id = error_id
            @error_shape = Model.shape(@model, error_id)
          end

          def error_name
            Model::Shape.name(@error_id)
          end

          def params
            ShapeToHash.transform_value(@model, test_case.fetch('params', {}), @error_shape)
          end

          def data_expect
            case test_case['bodyMediaType']
            when 'application/cbor'
              "expect(e.data.to_h).to match_cbor(#{params})"
            else
              "expect(e.data.to_h).to eq(#{params})"
            end
          end
        end
      end
    end
  end
end
