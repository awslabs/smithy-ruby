# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class Rubocop < View
        def initialize(plan)
          @plan = plan
          @model = plan.model
          super()
        end

        def gem_name
          if @plan.type == :types
            "#{@plan.options[:gem_name]}-types"
          else
            @plan.options[:gem_name]
          end
        end
      end
    end
  end
end
