$version: "2"

namespace smithy.ruby.tests

service ExamplesTrait {
    operations: [Operation]
}

@examples([
    {
        title: "Example",
        documentation: "This is an example",
        input: {
            string: "input",
            structure: {
                string: "structure"
            },
            list: [
                { string: "list" }
            ],
            map: {
                mapKey: { string: "map value" }
            }
        },
        output: {
            string: "output",
            structure: {
                string: "structure"
            },
            list: [
                { string: "list" }
            ],
            map: {
                mapKey: { string: "map value" }
            }
        }
    },
    {
        "title": "Error Example",
        "documentation": "This is an example with errors",
        input: {
            string: "bad input",
            structure: {
                string: "structure"
            },
            list: [
                { string: "list" }
            ],
            map: {
                mapKey: { string: "map value" }
            }
        },
        error: {
            shapeId: Error,
            content: {
                message: "This is an error"
            }
        }
    }
])
operation Operation {
    input: OperationInputOutput
    output: OperationInputOutput
    errors: [Error]
}

structure OperationInputOutput {
    string: String
    structure: Structure
    list: List
    map: Map
}

structure Structure {
    string: String
}

list List {
    member: Structure
}

map Map {
    key: String
    value: Structure
}

@error("client")
structure Error {
    message: String
}