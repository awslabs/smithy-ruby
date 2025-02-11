# frozen_string_literal: true

require 'smithy-client/protocols/rpc_v2'

module Smithy
  module Welds
    # Provides map of protocol trait id and its Ruby class name.
    # TODO: Update Welds to have a functionality to control ordering since there
    #  is a priority ordered list of protocols and a requirement that SDK MUST
    #  select the first entry in their priority ordered list that is also supported
    #  by the service. Generic code generation MUST accept configuration of this priority
    #  priority ordered list for use.
    #  The priority order is as follows (within AWS context):
    #  - Smithy RPCv2 CBOR
    #  - AWS JSON 1.0
    #  - AWS JSON 1.1
    #  - REST JSON
    #  - REST XML
    #  - AWS/Query
    #  - EC2/Query
    #  Possible solution: priority system similar to the handler registration
    class Protocols < Weld
      def protocols
        { 'smithy.protocols#rpcv2Cbor' => Smithy::Client::Protocols::RPCv2 }
      end
    end
  end
end
