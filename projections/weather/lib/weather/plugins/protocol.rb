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
        default: nil,
        doc_type: '#build, #parse, #error',
        docstring: <<~DOCS)
          This configuration is required to build requests and parse responses.
          In Smithy, a protocol is a named set of rules that defines the syntax
          and semantics of how a client and server communicate. The given protocol
          must provide the following functionalities:
          - `build`
          - `parse`
          - `error`
          See existing protocols within Smithy::Client::Protocols for examples.
        DOCS

      def add_handlers(handlers, _config)
        handlers.add(Smithy::Client::Handlers::Build)
        handlers.add(Smithy::Client::Handlers::Parse)
        # TODO: Requires error handling to be implemented
        # handlers.add(Smithy::Client::Handlers::Error, step: :sign)
      end
    end
  end
end
