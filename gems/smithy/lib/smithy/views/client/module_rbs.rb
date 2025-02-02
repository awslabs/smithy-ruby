# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class ModuleRbs < View
        def initialize(plan)
          @plan = plan
          @model = plan.model
          super()
        end

        def module_names
          @plan.module_name.split('::')
        end
      end
    end
  end
end
