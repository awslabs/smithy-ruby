# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class RubocopYml < View
        def initialize(plan)
          @plan = plan
          @model = plan.model
          super()
        end

        def gem_name
          if @plan.type == :schema
            "#{@plan.options[:gem_name]}-schema"
          else
            @plan.options[:gem_name]
          end
        end
      end
    end
  end
end
