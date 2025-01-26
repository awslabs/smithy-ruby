# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class EndpointPlugin < View
        def initialize(plan)
          @plan = plan
          @model = plan.model
          rules = EndpointRuleSet.new(plan).rules
          @parameters = rules['parameters'].map { |id, data| EndpointParameter.new(id, data, @plan) }

          super()
        end

        attr_reader :plan, :parameters
      end
    end
  end
end
