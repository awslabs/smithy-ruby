# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class EndpointParametersRbs < View
        def initialize(plan)
          @plan = plan
          @model = plan.model
          @module_name = plan.module_name
          service = @plan.service
          @endpoint_rules = service.values.first['traits']['smithy.rules#endpointRuleSet']
          @operations = Model::ServiceIndex.new(@model).operations_for(@plan.service)
          @parameters = @endpoint_rules['parameters']
                        .map { |id, data| EndpointParameter.new(id, data, @plan) }

          super()
        end

        attr_reader :module_name, :parameters
      end
    end
  end
end
