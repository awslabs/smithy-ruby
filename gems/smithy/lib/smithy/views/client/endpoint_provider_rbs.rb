# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class EndpointProviderRbs < View
        def initialize(plan)
          @plan = plan
          @namespace = plan.module_name
          super()
        end

        attr_reader :namespace
      end
    end
  end
end
