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
    input:= {
        map: StructureMap
    }
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
operation ListResources {
    output:= {
        list: StructureList
    }
}

operation ResourceOperation {
    input: Structure
}

operation CollectionResourceOperation {}

operation NestedResourceOperation {
    input: Structure
}

@documentation("This is a structure shape.")
structure Structure {
    @required
    id: String
    name: String
}

list StructureList {
    member: StructureMember
}

structure StructureMember {
    id: String
}

map StructureMap {
    key: MapKey
    value: MapValue
}

string MapKey

structure MapValue {
    id: String
}

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
