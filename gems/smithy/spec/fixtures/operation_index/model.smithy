$version: "2"

namespace smithy.ruby.tests

service OperationIndex {
    version: "1.0.0"
    operations: [Operation]
}

operation Operation {
    input: OperationInputOutput
    output: OperationInputOutput
    errors: [Error]
}

structure OperationInputOutput {
    structure: Structure
}

structure Structure {}

@error("client")
structure Error {
    member: Structure
}

structure OrphanedStructure {}

@error("client")
structure OrphanedError {}
