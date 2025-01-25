# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class EndpointBuiltInBindings
        DEFAULT_BINDINGS = {
          'SDK::Endpoint' => {
            render_config: proc do |_plan|
              <<~ADD_OPTION
                option(
                  :endpoint,
                  doc_type: String,
                  docstring: 'Custom Endpoint'
                )
              ADD_OPTION
            end,
            render_build: proc do |_plan|
              'config.endpoint'
            end,
            render_test_set: proc do |_plan, value|
              { 'endpoint' => value }
            end
          }
        }.freeze

        def initialize(plan)
          @bindings = endpoint_built_in_bindings(plan.welds)
        end

        attr_reader :bindings

        private

        def endpoint_built_in_bindings(welds)
          welded = welds.map(&:endpoint_built_in_bindings).reduce({}, :merge)
          DEFAULT_BINDINGS.merge(welded)
        end
      end
    end
  end
end