# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class RubocopYml < View
        def initialize(plan)
          @plan = plan
          super()
        end

        def gem_name
          @plan.gem_name
        end
      end
    end
  end
end
