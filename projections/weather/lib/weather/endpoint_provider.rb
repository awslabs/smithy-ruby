# frozen_string_literal: true

# This is generated code!

module Weather
  class EndpointProvider
    def resolve_endpoint(parameters)
      endpoint = parameters.endpoint

      # endpoint rules
      if Smithy::Client::EndpointRules.set?(endpoint)
        return Smithy::Client::EndpointRules::Endpoint.new(uri: 'endpoint')
      end

      raise ArgumentError, 'Endpoint is not set - you must configure an endpoint.'
      raise ArgumentError, 'No endpoint could be resolved'
    end
  end
end
