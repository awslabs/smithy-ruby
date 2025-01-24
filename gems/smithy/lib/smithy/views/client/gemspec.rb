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
          if @plan.type == :schema
            "#{@plan.options[:gem_name]}-schema"
          else
            @plan.options[:gem_name]
          end
        end

        def gem_version
          @plan.options[:gem_version]
        end
      end
    end
  end
end
