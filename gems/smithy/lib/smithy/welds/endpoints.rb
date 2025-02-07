# frozen_string_literal: true

module Smithy
  module Welds
    # Provides default endpoint builtin/function bindings.
    class Endpoints < Weld
      def pre_process(model)
        id, service = model['shapes'].select { |_k, s| s['type'] == 'service' }.first
        return if service['traits'] && service['traits']['smithy.rules#endpointRuleSet']

        say_status :insert, "Adding default endpoint rules to #{id}", @plan.quiet
        add_default_endpoints(service)
      end

      def endpoint_built_in_bindings
        {
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
        }
      end

      def endpoint_function_bindings
        {
          'isValidHostLabel' => 'Smithy::Client::EndpointRules.valid_host_label?',
          'parseURL' => 'Smithy::Client::EndpointRules.parse_url',
          'substring' => 'Smithy::Client::EndpointRules.substring',
          'uriEncode' => 'Smithy::Client::EndpointRules.uri_encode',
          'isSet' => 'Smithy::Client::EndpointRules.set?',
          'not' => 'Smithy::Client::EndpointRules.not',
          'getAttr' => 'Smithy::Client::EndpointRules.attr',
          'stringEquals' => 'Smithy::Client::EndpointRules.string_equals?',
          'booleanEquals' => 'Smithy::Client::EndpointRules.boolean_equals?'
        }
      end

      private

      def add_default_endpoints(service)
        service['traits'] ||= {}
        service['traits']['smithy.rules#endpointRuleSet'] = default_endpoint_rules
        service['traits']['smithy.rules#endpointTests'] = default_endpoint_tests
      end

      def default_endpoint_rules
        JSON.load_file(File.join(__dir__.to_s, 'default_endpoint_rules.json'))
      end

      def default_endpoint_tests
        JSON.load_file(File.join(__dir__.to_s, 'default_endpoint_tests.json'))
      end
    end
  end
end
