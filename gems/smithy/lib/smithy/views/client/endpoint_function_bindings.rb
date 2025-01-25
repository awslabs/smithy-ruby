# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class EndpointFunctionBindings
        DEFAULT_BINDINGS = {
          'isValidHostLabel' => 'Smithy::Client::EndpointRules.valid_host_label?',
          'parseURL' => 'Smithy::Client::EndpointRules.parse_url',
          'substring' => 'Smithy::Client::EndpointRules.substring',
          'uriEncode' => 'Smithy::Client::EndpointRules.uri_encode',
          'isSet' => 'Smithy::Client::EndpointRules.set?',
          'not' => 'Smithy::Client::EndpointRules.not',
          'getAttr' => 'Smithy::Client::EndpointRules.attr',
          'stringEquals' => 'Smithy::Client::EndpointRules.string_equals?',
          'booleanEquals' => 'Smithy::Client::EndpointRules.boolean_equals?'
        }.freeze

        def initialize(plan)
          @bindings = endpoint_function_bindings(plan.welds)
        end

        attr_reader :bindings

        private

        def endpoint_function_bindings(welds)
          welded = welds.map(&:endpoint_function_bindings).reduce({}, :merge)
          DEFAULT_BINDINGS.merge(welded)
        end
      end
    end
  end
end
