# frozen_string_literal: true

# This is generated code!

module Weather
  # Resolve endpoints from EndpointParameters.
  class EndpointProvider
    def resolve_endpoint(parameters)
      endpoint = parameters.endpoint

      return Smithy::Client::EndpointRules::Endpoint.new(uri: endpoint) if Smithy::Client::EndpointRules.set?(endpoint)

      raise ArgumentError, 'Endpoint is not set - you must configure an endpoint.'
    end
  end
end
