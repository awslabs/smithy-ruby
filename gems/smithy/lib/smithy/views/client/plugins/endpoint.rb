# frozen_string_literal: true

module Smithy
  module Views
    module Client
      module Plugins
        # @api private
        class Endpoint < View
          def initialize(plan)
            @plan = plan
            @model = plan.model
            service = @plan.service.values.first
            @endpoint_rules = service['traits']['smithy.rules#endpointRuleSet']
            @parameters = @endpoint_rules['parameters']
                          .map { |id, data| EndpointParameter.new(id, data, @plan) }

            super()
          end

          attr_reader :plan, :parameters

          def namespace
            Util::Namespace.namespace_from_gem_name(@plan.options[:gem_name])
          end

          def documentation
            '# TODO: Documentation'
          end
        end
      end
    end
  end
end
