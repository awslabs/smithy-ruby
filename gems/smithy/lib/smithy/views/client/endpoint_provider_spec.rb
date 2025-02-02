# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class EndpointProviderSpec < View
        def initialize(plan)
          @plan = plan
          @model = plan.model
          service = @plan.service.values.first
          @operations = Model::ServiceIndex.new(@model).operations_for(@plan.service)
          initialize_rules(service)
          initialize_tests(service)
          super()
        end

        attr_reader :parameters, :test_cases

        def module_name
          @plan.module_name
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
                        &.map { |data| EndpointTestCase.new(data, @plan, @operations) } || []
        end

        # @api private
        class EndpointTestCase
          def initialize(data, plan, operations)
            @plan = plan
            @documentation = data['documentation']
            @expect = data['expect']
            @operation_inputs = data.fetch('operationInputs', []).map do |d|
              OperationInputsTest.new(d, plan, operations)
            end
            @params = (data['params'] || {})&.transform_keys do |key|
              key.underscore.to_sym
            end
          end

          attr_reader :documentation, :expect, :params, :operation_inputs

          def expect_error?
            !@expect['error'].nil?
          end
        end

        # @api private
        class OperationInputsTest
          def initialize(data, plan, operations)
            @operation_name = data['operationName'].underscore
            @plan = plan
            @model = plan.model
            @service = @plan.service

            input = find_input(data, operations)

            @operation_params = build_operation_params(data, input)
            @client_params  = build_client_params(data)
          end

          attr_reader :operation_name, :operation_params, :client_params

          private

          def build_client_params(data)
            client_params = data.fetch('clientParams', {}).map do |k, v|
              Param.new(k.underscore, v)
            end

            client_params + data.fetch('builtInParams', {}).map do |k, v|
              built_in_to_param(k, v)
            end.flatten
          end

          def build_operation_params(data, input)
            data.fetch('operationParams', {}).map do |k, v|
              member_shape = @model['shapes'][input['members'][k]['target']]
              Param.new(k.underscore, transform_operation_values(v, member_shape))
            end
          end

          def find_input(data, operations)
            input_target = operations.find do |k, _v|
              k.split('#').last == data['operationName']
            end.last['input']['target']
            @model['shapes'][input_target]
          end

          def transform_operation_values(value, shape)
            return value unless shape

            case shape['type']
            when 'structure', 'union'
              transform_structure(shape, value)
            when 'list'
              transform_list(shape, value)
            when 'map'
              transform_map(shape, value)
            else
              value
            end
          end

          def transform_map(shape, value)
            member_shape = @model['shapes'][shape['value']['target']]
            value.transform_values do |v|
              transform_operation_values(v, member_shape)
            end
          end

          def transform_list(shape, value)
            member_shape = @model['shapes'][shape['member']['target']]
            value.map { |v| transform_operation_values(v, member_shape) }
          end

          def transform_structure(shape, value)
            value.each_with_object({}) do |(k, v), o|
              member_shape = @model['shapes'][shape['members'][k]['target']]
              o[k.underscore.to_sym] = transform_operation_values(v, member_shape)
            end
          end

          def built_in_bindings
            @built_in_bindings ||=
              @plan.welds
                   .map(&:endpoint_built_in_bindings)
                   .reduce({}, :merge)
          end

          def built_in_to_param(built_in, value)
            built_in_bindings[built_in][:render_test_set]
              .call(@plan, value)
              .map { |k, v| Param.new(k, v) }
          end
        end

        # @api private
        class Param
          def initialize(param, value, literal: false)
            @param = param
            @value = value
            @literal = literal
          end

          attr_accessor :param

          def value
            if @value.is_a?(String) && !@literal
              "'#{@value}'"
            else
              @value
            end
          end
        end
      end
    end
  end
end
