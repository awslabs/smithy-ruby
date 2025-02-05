# frozen_string_literal: true

module Smithy
  module Client
    module Protocols
      # RPCV2 protocol
      # TODO:
      #  * Refactor methods to handle eventstreams
      #  * Decide whether we should recognize query traits here
      #  * Add Documentation
      class RPCv2
        SHAPE_ID = 'smithy.protocols#rpcv2Cbor'

        def initialize(options = {})
          @query_compatible = options[:query_compatible]
        end

        def build_request(context)
          puts 'BUILDING REQUEST FROM RPCV2 PROTOCOL'
          codec = Client::Codecs::CBOR.new(setting(context))
          context.request.body = codec.serialize(context.params, context.operation.input)
          context.request.http_method = 'POST'
          apply_headers(context)
        end

        def parse_response(context)
          puts 'PARSING RESPONSE FROM RPCV2 PROTOCOL'
          output_shape = context.operation.output
          codec = Client::Codecs::CBOR.new(setting(context))
          codec.deserialize(context.response.body, output_shape, output_shape.type)
        end

        # TODO: Implement once errors are supported
        def parse_error(_context); end

        private

        def apply_headers(context)
          context.request.headers['X-Amzn-Query-Mode'] = 'true' if query_compatible?(context)
          context.request.headers['Smithy-Protocol'] = 'rpc-v2-cbor'
          context.request.headers['Content-Type'] = 'application/cbor'
          # TODO: Implement Content-Length Plugin/Handler
          context.request.headers['Content-Length'] = request.body.size
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
