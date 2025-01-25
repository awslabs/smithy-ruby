# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class EndpointTests
        def initialize(plan)
          _id, service = plan.service.first
          @tests = endpoint_tests(service)
        end

        attr_reader :tests

        private

        def endpoint_tests(service)
          rules = service.fetch('traits', {}).fetch('smithy.rules#endpointTests', nil)
          return rules if rules

          default = JSON.load_file(File.join(__dir__.to_s, 'default_endpoint_tests.json'))
          service['traits'] ||= {}
          service['traits']['smithy.rules#endpointTests'] = default
        end
      end
    end
  end
end
