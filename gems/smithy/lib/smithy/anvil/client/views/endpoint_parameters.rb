# frozen_string_literal: true

module Smithy
  module Anvil
    module Client
      module Views
        # @api private
        class EndpointParameters < View
          def initialize(plan)
            @plan = plan
            @model = plan.model
            service = @plan.service
            @endpoint_rules = service.values.first['traits']['smithy.rules#endpointRuleSet']
            @operations = Model::ServiceIndex.new(@model).operations_for(@plan.service)
            @parameters = @endpoint_rules['parameters']
                          .map { |id, data| EndpointParameter.new(id, data, @plan) }
            @operation_params = build_operation_params

            super()
          end

          attr_reader :parameters, :operation_params

          def namespace
            Util::Namespace.namespace_from_gem_name(@plan.options[:gem_name])
          end

          def documentation
            '# TODO: Documentation'
          end

          private

          def build_operation_params
            operation_params = {}
            @operations.each do |operation_id, operation|
              name = operation_id.split('#').last.underscore
              params = @endpoint_rules['parameters']
                       .map { |id, data| EndpointParameter.new(id, data, @plan, operation) }
                       .select { |p| p.source == 'operation' }
              operation_params[name] = params unless params.empty?
            end
            operation_params
          end
        end
      end
    end
  end
end
