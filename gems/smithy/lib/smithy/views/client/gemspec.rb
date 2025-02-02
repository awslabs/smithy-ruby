# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class Gemspec < View
        def initialize(plan)
          @plan = plan
          @gem_name = plan.gem_name
          @gem_version = plan.gem_version
          super()
        end

        attr_reader :gem_name, :gem_version
      end
    end
  end
end
