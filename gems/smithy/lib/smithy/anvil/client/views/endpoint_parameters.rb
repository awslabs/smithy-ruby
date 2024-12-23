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
            service = Vise::ServiceIndex.new(@model).service
            @endpoint_rules = service.values.first['traits']['smithy.rules#endpointRuleSet']
            @operations = Vise::OperationIndex.new(@model).for(service)
            @parameters = @endpoint_rules['parameters']
                          .map { |id, data| EndpointParameter.new(id, data, @plan) }

            super()
          end

          attr_reader :parameters

          def operation_specific_parameters?

          end

          def namespace
            Tools::Namespace.namespace_from_gem_name(@plan.options[:gem_name])
          end

          def documentation
            '# TODO: Documentation'
          end
        end
      end
    end
  end
end
