# frozen_string_literal: true

# This is generated code!

module Weather
  module Plugins
    # Protocol plugin
    class Protocol < Smithy::Client::Plugin
      option(
        :protocol,
        doc_default: 'Smithy::Client::Protocols::RPCV2',
        doc_type: 'Smithy::Client::Protocols::ProtocolBase',
        docstring: 'TODO'
      ) do |_cfg|
        Smithy::Client::Protocols::RPCV2.new
      end

      # @api private
      class Build < Smithy::Client::Handler
        def call(context)
          puts '**Calling from BuildHandler**'
          context.protocol.build_request(context)
          @handler.call(context)
        end
      end

      # @api private
      class Parse < Smithy::Client::Handler
        def call(context)
          puts '**Calling from ParseHandler**'
          resp = @handler.call(context)
          context.protocol.parse_response(context)
          resp
        end
      end

      def add_handlers(handlers, _config)
        handlers.add(Build)
        handlers.add(Parse)
      end
    end
  end
end
