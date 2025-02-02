# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class Gemspec < View
        def initialize(plan)
          @plan = plan
          super()
        end

        def gem_name
          @plan.gem_name
        end

        def gem_version
          @plan.gem_version
        end
      end
    end
  end
end
