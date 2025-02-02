# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class EndpointProviderRbs < View
        def initialize(plan)
          @plan = plan
          super()
        end

        def module_name
          @plan.module_name
        end
      end
    end
  end
end
