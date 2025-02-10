# frozen_string_literal: true

require_relative 'protocols/rpc_v2'

module Smithy
  module Client
    # In Smithy, a protocol is a named set of rules that defines the
    # syntax and semantics of how a client and server communicate. To
    # use a {Smithy::Client}, a protocol is required to be set on
    # {Configuration}.
    #
    # We currently support the following protocols:
    #
    # - {RPCv2}, a RPC-based protocol over HTTP that sends requests
    # and responses with CBOR payloads.
    #
    # You could also create a custom protocol to pass into the client
    # configuration. The given protocol must provide the following
    # functionalities:
    #
    #  - `build` - builds the request
    #  - `parse` - parse the response
    #  - `error` - extracts the error from response
    #
    # See {RPCv2} as an example implementation.
    module Protocols; end
  end
end
