# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class EndpointPlugin < View
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
          @plan.module_name
        end
      end
    end
  end
end
