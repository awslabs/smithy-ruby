$version: "2.0"

namespace smithy.protocoltests.rpcv2Cbor
use smithy.ruby#skipTests

apply OperationWithDefaults @skipTests([
  { id: "RpcV2CborClientPopulatesDefaultValuesInInput", reason: "Defaults not Implemented yet.", type: "request" }
])