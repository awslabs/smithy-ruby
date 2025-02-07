# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class ProtocolSpec < View
        def initialize(plan)
          @plan = plan
          @model = plan.model
          service = @plan.service.values.first
          @operations = Model::ServiceIndex.new(@model).operations_for(@plan.service)
          super()
        end

        def module_name
          @plan.module_name
        end

      end
    end
  end
end
