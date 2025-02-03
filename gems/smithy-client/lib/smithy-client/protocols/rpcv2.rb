# frozen_string_literal: true

module Smithy
  module Client
    module Protocols
      # RPCV2 protocol
      class RPCV2 < ProtocolBase
        def initialize
          super('smithy.protocols#rpcv2Cbor')
        end

        def build_request(context)
          puts 'BUILDING REQUEST FROM RPCV2 PROTOCOL'
          input_shape = context.operation.input
          context.request.http_method = 'POST'
          codec = Client::Codecs::CBOR.new(codec_setting(input_shape))
          context.request.body = codec.serialize(context.params, input_shape)
          apply_headers(context.request)
        end

        def parse_response(context)
          puts 'PARSING RESPONSE FROM RPCV2 PROTOCOL'
          # TODO: Need to refactor to handle eventstreams
          output_shape = context.operation.output
          codec = Client::Codecs::CBOR.new(codec_setting(output_shape))
          codec.deserialize(context.response.body, output_shape, output_shape.type)
        end

        # TODO: Implement ContentType Handler specific to RPCV2
        def apply_content_type(context)
          context.request.headers['Content-Type'] = 'application/cbor'
        end

        private

        def apply_headers(request)
          # TODO: Add X-Amz-Query-Mode header if aws.protocols#awsQueryCompatible is true
          request.headers['Smithy-Protocol'] = 'rpc-v2-cbor'
          # TODO: Remove after implementing ContentLength Plugin/Handler
          request.headers['Content-Length'] = request.body.size
        end

        def codec_setting(_shape)
          # TODO: Filter codec traits, depending on context
          {}
        end
      end
    end
  end
end
