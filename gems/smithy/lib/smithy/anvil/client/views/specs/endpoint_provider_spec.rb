# frozen_string_literal: true

module Smithy
  module Anvil
    module Client
      module Views
        module Specs
          # @api private
          class EndpointProviderSpec < View
            def initialize(plan)
              @plan = plan
              @model = plan.model
              service = Vise::ServiceIndex.new(@model).service.values.first
              initialize_rules(service)
              initialize_tests(service)

              super()
            end

            attr_reader :parameters, :test_cases

            def namespace
              Tools::Namespace.namespace_from_gem_name(@plan.options[:gem_name])
            end

            def documentation
              '# TODO: Documentation'
            end

            private

            def initialize_rules(service)
              @endpoint_rules = service['traits']['smithy.rules#endpointRuleSet']

              @parameters = @endpoint_rules['parameters']
                            .map { |id, data| EndpointParameter.new(id, data, @plan) }
            end

            def initialize_tests(service)
              @endpoint_tests = service['traits']['smithy.rules#endpointTests'] || {}
              @test_cases = @endpoint_tests['testCases']
                            &.map { |data| EndpointTestCase.new(data, @plan) }
              @initialize_tests ||= []
            end

            # @api private
            class EndpointTestCase
              def initialize(data, plan)
                @data = data
                @plan = plan

                @documentation = data['documentation']
                @expect = data['expect']
                @operation_inputs = data['operationInputs']
                @params = data['params']&.transform_keys do |key|
                  key.underscore.to_sym
                end
                @params ||= {}
              end

              attr_reader :expect, :documentation, :params, :operation_inputs

              def expect_error?
                !@expect['error'].nil?
              end
            end
          end
        end
      end
    end
  end
end
