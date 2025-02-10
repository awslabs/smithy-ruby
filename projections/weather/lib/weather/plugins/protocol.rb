# frozen_string_literal: true

# This is generated code!

module Weather
  module Plugins
    # Protocol plugin - allows user to configure protocol on client.
    # TODO: Add convenience mapping - see https://github.com/smithy-lang/smithy-ruby/pull/264/files#r1946524403
    # @api private
    class Protocol < Smithy::Client::Plugin
      option(
        :protocol,
        doc_default: 'Smithy::Client::Protocols::RPCv2',
        doc_type: 'Smithy::Client::Protocols::RPCv2',
        docstring: <<~DOCS) do |_cfg|
          Allows you to overwrite default protocol. The given protocol
          must provide the following functionalities:
          - `build`
          - `parse`
          - `error`
          See existing protocols within Smithy::Client::Protocols for examples.
        DOCS
        Smithy::Client::Protocols::RPCv2.new
      end

      def add_handlers(handlers, _config)
        handlers.add(Smithy::Client::Handlers::Build)
        handlers.add(Smithy::Client::Handlers::Parse)
        # TODO: Requires error handling to be implemented
        # handlers.add(Smithy::Client::Handlers::Error, step: :sign)
      end
    end
  end
end
