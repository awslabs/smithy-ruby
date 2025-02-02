# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class RubocopYml < View
        def initialize(plan)
          @plan = plan
          @gem_name = plan.gem_name
          super()
        end

        attr_reader :gem_name
      end
    end
  end
end
