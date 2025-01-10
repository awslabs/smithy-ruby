# frozen_string_literal: true

# This is generated code!

module Weather
  module Plugins
    # Endpoint plugin - resolves the endpoint and applies it to the request.
    # @api private
    class Endpoint < Smithy::Client::Plugin
      option(
        :endpoint_provider,
        doc_type: 'Weather::EndpointProvider',
        docstring: <<~DOCS) do |_cfg|
          The endpoint provider used to resolve endpoints. Any object that responds to
          `#resolve_endpoint(parameters)`.
        DOCS
        EndpointProvider.new
      end

      option(
        :endpoint,
        doc_type: String,
        docstring: 'Custom Endpoint'
      )

      # @api private
      class Handler < Smithy::Client::Handler
        def call(context)
          params = EndpointParameters.create(context)
          endpoint = context.config.endpoint_provider.resolve_endpoint(params)

          context.request.endpoint = endpoint.uri
          apply_endpoint_headers(context, endpoint.headers)

          context[:endpoint_params] = params

          # TODO: apply auth schemes (update signer properties from resolved auth scheme).

          @handler.call(context)
        end

        private

        def apply_endpoint_headers(context, headers)
          headers.each do |key, value|
            context.request.headers[key] = value
          end
        end
      end

      def add_handlers(handlers, _config)
        handlers.add(Handler, step: :build, priority: 75)
      end
    end
  end
end
