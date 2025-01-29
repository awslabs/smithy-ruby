# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class EndpointParametersRbs < View
        def initialize(plan)
          @plan = plan
          @model = plan.model
          service = @plan.service
          @endpoint_rules = service.values.first['traits']['smithy.rules#endpointRuleSet']
          @operations = Model::ServiceIndex.new(@model).operations_for(@plan.service)
          @parameters = @endpoint_rules['parameters']
                        .map { |id, data| EndpointParameter.new(id, data, @plan) }

          super()
        end

        attr_reader :parameters

        def namespace
          Util::Namespace.namespace_from_gem_name(@plan.options[:gem_name])
        end
      end
    end
  end
end
