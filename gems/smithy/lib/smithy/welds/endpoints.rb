# frozen_string_literal: true

module Smithy
  module Welds
    # Provides default endpoint builtin/function bindings.
    class Endpoints < Weld
      def preprocess(model)
        model['shapes'].select { |_k, s| s['type'] == 'service' }.each_value do |shape|
          add_default_endpoints(shape['traits']) unless shape['traits']['smithy.rules#endpointRuleSet']
        end
      end

      def endpoint_built_in_bindings
        {
          'SDK::Endpoint' => {
            # Text indenting is used in generated view.
            render_config: proc do |_plan|
              <<-ADD_OPTION
      option(
        :endpoint,
        doc_type: String,
        docstring: "Custom Endpoint"
      )
              ADD_OPTION
            end,
            render_build: proc do |_plan, _operation|
              'config.endpoint'
            end,
            render_test_set: proc do |_plan, _operation, _node|
            end
          }
        }
      end

      def endpoint_function_bindings
        {
          'isValidHostLabel' => 'Smithy::Client::EndpointRules::valid_host_label?',
          'parseURL' => 'Smithy::Client::EndpointRules::parse_url',
          'substring' => 'Smithy::Client::EndpointRules::substring',
          'uriEncode' => 'Smithy::Client::EndpointRules::uri_encode',
          'isSet' => 'Smithy::Client::EndpointRules::set?',
          'not' => 'Smithy::Client::EndpointRules::not',
          'getAttr' => 'Smithy::Client::EndpointRules::attr',
          'stringEquals' => 'Smithy::Client::EndpointRules::string_equals?',
          'booleanEquals' => 'Smithy::Client::EndpointRules::boolean_equals?'
        }
      end

      private

      def add_default_endpoints(service_traits)
        service_traits['smithy.rules#endpointRuleSet'] = default_endpoint_rules
        service_traits['smithy.rules#endpointTests'] = default_endpoint_tests
      end

      def default_endpoint_rules
        JSON.load_file(File.join(__dir__, 'default_endpoint_rules.json'))
      end

      def default_endpoint_tests
        JSON.load_file(File.join(__dir__, 'default_endpoint_rules.json'))
      end
    end
  end
end
