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

      def built_in_bindings
        [Vise::Endpoints::BuiltInBinding.new(
          id: 'SDK::Endpoint',
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
        )]
      end

      def function_bindings
        # TODO: Add all stdlib from:
        # https://github.com/smithy-lang/smithy-ruby/blob/main/codegen/smithy-ruby-codegen/src/main/java/software/amazon/smithy/ruby/codegen/rulesengine/FunctionBinding.java#L49
        [
          Vise::Endpoints::FunctionBinding.new(
            id: 'isValidHostLabel',
            ruby_method: 'Smithy::Client::EndpointRules::valid_host_label?'
          ),
          Vise::Endpoints::FunctionBinding.new(
            id: 'parseURL',
            ruby_method: 'Smithy::Client::EndpointRules::parse_url'
          ),
          Vise::Endpoints::FunctionBinding.new(
            id: 'substring',
            ruby_method: 'Smithy::Client::EndpointRules::substring'
          ),
          Vise::Endpoints::FunctionBinding.new(
            id: 'uriEncode',
            ruby_method: 'Smithy::Client::EndpointRules::uri_encode'
          ),
          Vise::Endpoints::FunctionBinding.new(
            id: 'isSet',
            ruby_method: 'Smithy::Client::EndpointRules::set?'
          ),
          Vise::Endpoints::FunctionBinding.new(
            id: 'not',
            ruby_method: 'Smithy::Client::EndpointRules::not'
          ),
          Vise::Endpoints::FunctionBinding.new(
            id: 'getAttr',
            ruby_method: 'Smithy::Client::EndpointRules::attr'
          ),
          Vise::Endpoints::FunctionBinding.new(
            id: 'stringEquals',
            ruby_method: 'Smithy::Client::EndpointRules::string_equals?'
          ),
          Vise::Endpoints::FunctionBinding.new(
            id: 'booleanEquals',
            ruby_method: 'Smithy::Client::EndpointRules::boolean_equals?'
          )
        ]
      end

      private

      def add_default_endpoints(service_traits)
        service_traits['smithy.rules#endpointRuleSet'] = default_endpoint_rules
        service_traits['smithy.rules#endpointTests'] = default_endpoint_tests
      end

      # rubocop:disable Metrics/MethodLength:
      def default_endpoint_rules
        JSON.parse(<<~JSON)
          {
            "version": "1.0",
            "parameters": {
                "endpoint": {
                    "type": "string",
                    "builtIn": "SDK::Endpoint",
                    "documentation": "Endpoint"
                }
            },
            "rules": [
                {
                    "conditions": [
                        {
                            "fn": "isSet",
                            "argv": [
                                {
                                    "ref": "endpoint"
                                }
                            ]
                        }
                    ],
                    "endpoint": {
                        "url": "endpoint"
                    },
                    "type": "endpoint"
                },
                {
                    "conditions": [],
                    "error": "Endpoint is not set - you must configure an endpoint.",
                    "type": "error"
                }
            ]
          }
        JSON
      end
      # rubocop:enable Metrics/MethodLength:

      def default_endpoint_tests
        # TODO: Add default test cases
        JSON.parse(<<~JSON)
          {
            "version": "1.0",
            "testCases": []
          }
        JSON
      end
    end
  end
end
