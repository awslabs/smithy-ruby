# frozen_string_literal: true

# This is generated code!

module Weather
  module Plugins
    # Protocol plugin - allows user to configure protocol on client.
    # @api private
    class Protocol < Smithy::Client::Plugin
      option(
        :protocol,
        doc_default: 'Smithy::Client::Protocols::RPCv2',
        doc_type: 'Smithy::Client::Protocols::RPCv2',
        docstring: <<~DOCS) do |_cfg|
          Allows you to overwrite default protocol. The given protocol
          must provide the following functionalities:
          - `build_request`
          - `parse_response`
          - `parse_error`
          See existing protocols within Smithy::Client::Protocols for examples.
        DOCS
        Smithy::Client::Protocols::RPCv2.new
      end

      # @api private
      class Build < Smithy::Client::Handler
        def call(context)
          context.config.protocol.build_request(context)
          @handler.call(context)
        end
      end

      # @api private
      class Parse < Smithy::Client::Handler
        def call(context)
          resp = @handler.call(context)
          context.config.protocol.parse_response(context)
          resp
        end
      end

      # @api private
      class Error < Smithy::Client::Handler
        def call(context)
          @handler.call(context).on(300..599) do |response|
            context.config.protocol.parse_error(context, response)
          end
        end
      end

      def add_handlers(handlers, _config)
        handlers.add(Build)
        handlers.add(Parse)
        # TODO: Requires error handling to be implemented
        # handlers.add(Error, step: :sign)
      end
    end
  end
end
