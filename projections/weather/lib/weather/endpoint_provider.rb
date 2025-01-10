# frozen_string_literal: true

# This is generated code!

module Weather
  # Resolve an endpoint from {EndpointParameters}.
  class EndpointProvider
    # @param [EndpointParameters] parameters
    # @return [Smithy::Client::EndpointRules::Endpoint]
    # @raise [ArgumentError]
    def resolve_endpoint(parameters)
      endpoint = parameters.endpoint

      if Smithy::Client::EndpointRules.set?(endpoint)
        return Smithy::Client::EndpointRules::Endpoint.new(uri: endpoint)
      end
      raise ArgumentError, "Endpoint is not set - you must configure an endpoint."
    end
  end
end
