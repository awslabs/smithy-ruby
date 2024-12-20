$version: "2"

namespace smithy.ruby.tests

service Vise {
    version: "1.0.0"
    operations: [Operation]
    resources: [Resource]
    errors: [Error]
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
    input: Structure
    output: Structure
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

operation OrphanedOperation {}

@error("client")
structure Error {
    member: String
}

enum Enum {
    VALUE
}

intEnum IntEnum {
    VALUE = 0
}

list List {
    member: Structure
}

map Map {
    key: String
    value: Structure
}

@documentation("This is a structure shape.")
structure Structure {
    @required
    id: String
    name: String
}

union Union {
    member: Structure
}