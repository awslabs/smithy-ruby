$version: "2"

namespace smithy.ruby.tests

use smithy.protocols#rpcv2Cbor

// Define a fake protocol trait for use.
@trait
@protocolDefinition
structure testProtocol {}

@testProtocol
@rpcv2Cbor
service MultiProtocol { }
