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

        def dependencies
          if @plan.type == :schema
            { 'smithy-model' => '~> 1' }
          else
            { 'smithy-client' => '~> 1' }
          end
        end
      end
    end
  end
end
