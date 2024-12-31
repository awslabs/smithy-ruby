# frozen_string_literal: true

module Smithy
  module Anvil
    module Client
      module Views
        module Specs
          # @api private
          class SpecHelper < View
            def initialize(plan)
              @plan = plan
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
  end
end
