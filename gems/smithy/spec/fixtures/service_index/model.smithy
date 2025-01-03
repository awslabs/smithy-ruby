$version: "2"

namespace smithy.ruby.tests

service ServiceIndex {
    version: "1.0.0"
    operations: [Operation]
    resources: [Resource]
    errors: [ServiceError]
}

resource Resource {
    identifiers: { id: String }
    properties: { name: String }
    create: CreateResource
    put: PutResource
    read: ReadResource
    update: UpdateResource
    delete: DeleteResource
    list: ListResources
    operations: [ResourceOperation]
    collectionOperations: [CollectionResourceOperation]
    resources: [NestedResource]
}

resource NestedResource {
    identifiers: { id: String }
    operations: [NestedResourceOperation]
}

operation Operation {
    input: OperationInput
    output: Structure
    errors: [OperationError]
}

operation CreateResource {}

@idempotent
operation PutResource {
    input: Structure
}

@readonly
operation ReadResource {
    input: Structure
}

operation UpdateResource {
    input: Structure
}

@idempotent
operation DeleteResource {
    input: Structure
}

@readonly
operation ListResources {}

operation ResourceOperation {
    input: Structure
}

operation CollectionResourceOperation {}

operation NestedResourceOperation {
    input: Structure
}

structure OperationInput {
    map: Map
    list: List
}


@documentation("This is a structure shape.")
structure Structure {
    @required
    id: String
    name: String
}

list List {
    member: ListMember
}

string ListMember

map Map {
    key: MapKey
    value: MapValue
}

string MapKey

string MapValue

@error("client")
structure ServiceError {
    member: String
}

@error("client")
structure OperationError {
    member: String
}

operation OrphanedOperation {}

structure OrphanedStructure {}

@error("client")
structure OrphanedError {}
