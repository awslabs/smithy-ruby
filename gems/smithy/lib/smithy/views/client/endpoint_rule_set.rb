# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class EndpointRuleSet
        def initialize(plan)
          _id, service = plan.service.first
          @rules = endpoint_rules(service)
        end

        attr_reader :rules

        private

        def endpoint_rules(service)
          rules = service.fetch('traits', {}).fetch('smithy.rules#endpointRuleSet', nil)
          return rules if rules

          default = JSON.load_file(File.join(__dir__.to_s, 'default_endpoint_rules.json'))
          service['traits'] ||= {}
          service['traits']['smithy.rules#endpointRuleSet'] = default
        end
      end
    end
  end
end