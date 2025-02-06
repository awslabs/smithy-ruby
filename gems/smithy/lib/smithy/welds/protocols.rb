# frozen_string_literal: true

require 'smithy-client/protocols/rpc_v2'

module Smithy
  module Welds
    # Provides map of protocol trait id and its Ruby class name.
    class Protocols < Weld
      def protocols
        { 'smithy.protocols#rpcv2Cbor' => Smithy::Client::Protocols::RPCv2 }
      end
    end
  end
end
