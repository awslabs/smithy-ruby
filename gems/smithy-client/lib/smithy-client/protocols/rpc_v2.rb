# frozen_string_literal: true

module Smithy
  module Client
    module Protocols
      # A RPC-based protocol over HTTP that sends requests
      # and responses with CBOR payloads.
      #
      # TODO: Refactor methods to handle eventstreams
      class RPCv2
        SHAPE_ID = 'smithy.protocols#rpcv2Cbor'

        def initialize(options = {})
          @query_compatible = options[:query_compatible]
        end

        # @api private
        def build(context)
          codec = Client::Codecs::CBOR.new(setting(context))
          context.request.body = codec.serialize(context.params, context.operation.input)
          context.request.http_method = 'POST'
          apply_headers(context)
          build_url(context)
        end

        # @api private
        def parse(context)
          output_shape = context.operation.output
          codec = Client::Codecs::CBOR.new(setting(context))
          codec.deserialize(context.response.body, output_shape, output_shape.type)
        end

        # @api private
        # TODO: To implement after error handling
        def error(_context, _response); end

        private

        def apply_headers(context)
          context.request.headers['X-Amzn-Query-Mode'] = 'true' if query_compatible?(context)
          context.request.headers['Smithy-Protocol'] = 'rpc-v2-cbor'
          context.request.headers['Content-Type'] = 'application/cbor'
          # TODO: Implement Content-Length Plugin/Handler
          context.request.headers['Content-Length'] = context.request.body.size
        end

        def build_url(context)
          base = context.request.endpoint
          base.path +=
            "/service/#{context.config.schema.service.name}/operation/#{context.operation.name}"
        end

        def setting(context)
          {}.tap do |h|
            h[:query_compatible] = true if query_compatible?(context)
          end
        end

        def query_compatible?(context)
          @query_compatible ||
            context.config.schema.service.traits.one? { |k, _v| k == 'aws.protocols#awsQuery' }
        end
      end
    end
  end
end
