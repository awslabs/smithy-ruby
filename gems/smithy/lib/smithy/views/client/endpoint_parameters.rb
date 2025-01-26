# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class EndpointParameters < View
        def initialize(plan)
          @plan = plan
          rules = EndpointRuleSet.new(plan).rules
          @parameters = endpoint_parameters(rules)
          @operation_params = build_operation_params(rules)
          super()
        end

        attr_reader :parameters, :operation_params

        private

        def endpoint_parameters(rules)
          rules['parameters'].map { |id, data| EndpointParameter.new(id, data, @plan) }
        end

        def build_operation_params(rules)
          operations = Model::ServiceIndex.new(@plan.model).operations_for(@plan.service)
          operations.each_with_object({}) do |(id, operation), operation_params|
            name = Model::Shape.name(id).underscore
            params = operation_endpoint_parameters(rules, operation)
            operation_params[name] = params unless params.empty?
          end
        end

        def operation_endpoint_parameters(rules, operation)
          rules['parameters']
            .map { |name, value| EndpointParameter.new(name, value, @plan, operation) }
            .select { |p| p.source == 'operation' }
        end
      end
    end
  end
end
