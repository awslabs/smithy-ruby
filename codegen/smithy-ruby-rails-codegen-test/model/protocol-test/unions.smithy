// This file defines test cases that serialize unions.

$version: "2.0"

namespace smithy.ruby.protocoltests.railsjson

use smithy.ruby.protocols#railsJson
use smithy.test#httpRequestTests
use smithy.test#httpResponseTests
use aws.protocoltests.shared#StringList
use aws.protocoltests.shared#StringMap
use aws.protocoltests.shared#GreetingStruct
use aws.protocoltests.shared#FooEnum


/// This operation uses unions for inputs and outputs.
@idempotent
@http(uri: "/json_unions", method: "PUT")
operation JsonUnions {
    input: UnionInputOutput,
    output: UnionInputOutput,
}

/// A shared structure that contains a single union member.
structure UnionInputOutput {
    contents: MyUnion
}

/// A union with a representative set of types for members.
union MyUnion {
    stringValue: String,
    booleanValue: Boolean,
    numberValue: Integer,
    blobValue: Blob,
    timestampValue: Timestamp,
    enumValue: FooEnum,
    listValue: StringList,
    mapValue: StringMap,
    structureValue: GreetingStruct,

    // Note that this uses a conflicting structure name with
    // GreetingStruct, so it must be renamed in the service.
    renamedStructureValue: smithy.ruby.protocoltests.railsjson.nested#GreetingStruct,
}

apply JsonUnions @httpRequestTests([
    {
        id: "RailsJsonSerializeStringUnionValue",
        documentation: "Serializes a string union value",
        protocol: railsJson,
        method: "PUT",
        "uri": "/JsonUnions",
        body: """
            {
                "contents": {
                    "stringValue": "foo"
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            contents: {
                stringValue: "foo"
            }
        }
    },
    {
        id: "RailsJsonSerializeBooleanUnionValue",
        documentation: "Serializes a boolean union value",
        protocol: railsJson,
        method: "PUT",
        "uri": "/JsonUnions",
        body: """
            {
                "contents": {
                    "booleanValue": true
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            contents: {
                booleanValue: true
            }
        }
    },
    {
        id: "RailsJsonSerializeNumberUnionValue",
        documentation: "Serializes a number union value",
        protocol: railsJson,
        method: "PUT",
        "uri": "/JsonUnions",
        body: """
            {
                "contents": {
                    "numberValue": 1
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            contents: {
                numberValue: 1
            }
        }
    },
    {
        id: "RailsJsonSerializeBlobUnionValue",
        documentation: "Serializes a blob union value",
        protocol: railsJson,
        method: "PUT",
        "uri": "/JsonUnions",
        body: """
            {
                "contents": {
                    "blobValue": "Zm9v"
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            contents: {
                blobValue: "foo"
            }
        }
    },
    {
        id: "RailsJsonSerializeTimestampUnionValue",
        documentation: "Serializes a timestamp union value",
        protocol: railsJson,
        method: "PUT",
        "uri": "/JsonUnions",
        body: """
            {
                "contents": {
                    "timestampValue": 1398796238
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            contents: {
                timestampValue: 1398796238
            }
        }
    },
    {
        id: "RailsJsonSerializeEnumUnionValue",
        documentation: "Serializes an enum union value",
        protocol: railsJson,
        method: "PUT",
        "uri": "/JsonUnions",
        body: """
            {
                "contents": {
                    "enumValue": "Foo"
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            contents: {
                enumValue: "Foo"
            }
        }
    },
    {
        id: "RailsJsonSerializeListUnionValue",
        documentation: "Serializes a list union value",
        protocol: railsJson,
        method: "PUT",
        "uri": "/JsonUnions",
        body: """
            {
                "contents": {
                    "listValue": ["foo", "bar"]
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            contents: {
                listValue: ["foo", "bar"]
            }
        }
    },
    {
        id: "RailsJsonSerializeMapUnionValue",
        documentation: "Serializes a map union value",
        protocol: railsJson,
        method: "PUT",
        "uri": "/JsonUnions",
        body: """
            {
                "contents": {
                    "mapValue": {
                        "foo": "bar",
                        "spam": "eggs"
                    }
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            contents: {
                mapValue: {
                    foo: "bar",
                    spam: "eggs",
                }
            }
        }
    },
    {
        id: "RailsJsonSerializeStructureUnionValue",
        documentation: "Serializes a structure union value",
        protocol: railsJson,
        method: "PUT",
        "uri": "/JsonUnions",
        body: """
            {
                "contents": {
                    "structureValue": {
                        "hi": "hello"
                    }
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            contents: {
                structureValue: {
                    hi: "hello",
                }
            }
        }
    },
    {
        id: "RailsJsonSerializeRenamedStructureUnionValue",
        documentation: "Serializes a renamed structure union value",
        protocol: railsJson,
        method: "PUT",
        uri: "/json_unions",
        body: """
            {
                "contents": {
                    "renamedStructureValue": {
                        "salutation": "hello!"
                    }
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            contents: {
                renamedStructureValue: {
                    salutation: "hello!",
                }
            }
        }
    },
])

apply JsonUnions @httpResponseTests([
    {
        id: "RailsJsonDeserializeStringUnionValue",
        documentation: "Deserializes a string union value",
        protocol: railsJson,
        code: 200,
        body: """
            {
                "contents": {
                    "stringValue": "foo"
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            contents: {
                stringValue: "foo"
            }
        }
    },
    {
        id: "RailsJsonDeserializeBooleanUnionValue",
        documentation: "Deserializes a boolean union value",
        protocol: railsJson,
        code: 200,
        body: """
            {
                "contents": {
                    "booleanValue": true
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            contents: {
                booleanValue: true
            }
        }
    },
    {
        id: "RailsJsonDeserializeNumberUnionValue",
        documentation: "Deserializes a number union value",
        protocol: railsJson,
        code: 200,
        body: """
            {
                "contents": {
                    "numberValue": 1
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            contents: {
                numberValue: 1
            }
        }
    },
    {
        id: "RailsJsonDeserializeBlobUnionValue",
        documentation: "Deserializes a blob union value",
        protocol: railsJson,
        code: 200,
        body: """
            {
                "contents": {
                    "blobValue": "Zm9v"
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            contents: {
                blobValue: "foo"
            }
        }
    },
    {
        id: "RailsJsonDeserializeTimestampUnionValue",
        documentation: "Deserializes a timestamp union value",
        protocol: railsJson,
        code: 200,
        body: """
            {
                "contents": {
                    "timestampValue": 1398796238
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            contents: {
                timestampValue: 1398796238
            }
        }
    },
    {
        id: "RailsJsonDeserializeEnumUnionValue",
        documentation: "Deserializes an enum union value",
        protocol: railsJson,
        code: 200,
        body: """
            {
                "contents": {
                    "enumValue": "Foo"
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            contents: {
                enumValue: "Foo"
            }
        }
    },
    {
        id: "RailsJsonDeserializeListUnionValue",
        documentation: "Deserializes a list union value",
        protocol: railsJson,
        code: 200,
        body: """
            {
                "contents": {
                    "listValue": ["foo", "bar"]
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            contents: {
                listValue: ["foo", "bar"]
            }
        }
    },
    {
        id: "RailsJsonDeserializeMapUnionValue",
        documentation: "Deserializes a map union value",
        protocol: railsJson,
        code: 200,
        body: """
            {
                "contents": {
                    "mapValue": {
                        "foo": "bar",
                        "spam": "eggs"
                    }
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            contents: {
                mapValue: {
                    foo: "bar",
                    spam: "eggs",
                }
            }
        }
    },
    {
        id: "RailsJsonDeserializeStructureUnionValue",
        documentation: "Deserializes a structure union value",
        protocol: railsJson,
        code: 200,
        body: """
            {
                "contents": {
                    "structureValue": {
                        "hi": "hello"
                    }
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            contents: {
                structureValue: {
                    hi: "hello",
                }
            }
        }
    },
    {
        id: "RailsJsonDeserializeIgnoreType"
        appliesTo: "client"
        documentation: "Ignores an unrecognized __type property"
        protocol: railsJson
        code: 200
        body: """
            {
                "contents": {
                    "__type": "aws.protocoltests.json10#MyUnion",
                    "structureValue": {
                        "hi": "hello"
                    }
                }
            }"""
        bodyMediaType: "application/json"
        headers: {
            "Content-Type": "application/json"
        }
        params: {
            contents: {
                structureValue: {
                    hi: "hello"
                }
            }
        }
    }
])


/// This operation defines a union with a Unit member.
@http(uri: "/post_player_action", method: "POST")
operation PostPlayerAction {
    input: PostPlayerActionInput,
    output: PostPlayerActionOutput
}

@input
structure PostPlayerActionInput {
    action: PlayerAction
}

@output
structure PostPlayerActionOutput {
    @required
    action: PlayerAction
}

union PlayerAction {
    /// Quit the game.
    quit: Unit
}

apply PostPlayerAction @httpRequestTests([
    {
        id: "RailsJsonInputUnionWithUnitMember",
        documentation: "Unit types in unions are serialized like normal structures in requests.",
        protocol: railsJson,
        method: "POST",
        uri: "/post_player_action",
        body: """
            {
                "action": {
                    "quit": {}
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            action: {
                quit: {}
            }
        }
    }
])

apply PostPlayerAction @httpResponseTests([
    {
        id: "RailsJsonOutputUnionWithUnitMember",
        documentation: "Unit types in unions are serialized like normal structures in responses.",
        protocol: railsJson,
        code: 200,
        body: """
            {
                "action": {
                    "quit": {}
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            action: {
                quit: {}
            }
        }
    }
])


/// This operation defines a union that uses jsonName on some members.
@http(uri: "/post_union_with_json_name", method: "POST")
operation PostUnionWithJsonName {
    input: PostUnionWithJsonNameInput,
    output: PostUnionWithJsonNameOutput
}

@input
structure PostUnionWithJsonNameInput {
    value: UnionWithJsonName
}

@output
structure PostUnionWithJsonNameOutput {
    @required
    value: UnionWithJsonName
}

union UnionWithJsonName {
    @jsonName("FOO")
    foo: String,

    bar: String,

    @jsonName("_baz")
    baz: String
}

apply PostUnionWithJsonName @httpRequestTests([
    {
        id: "RailsJsonPostUnionWithJsonNameRequest1",
        documentation: "Tests that jsonName works with union members.",
        protocol: railsJson,
        method: "POST",
        uri: "/post_union_with_json_name",
        body: """
            {
                "value": {
                    "FOO": "hi"
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            value: {
                foo: "hi"
            }
        }
    },
    {
        id: "RailsJsonPostUnionWithJsonNameRequest2",
        documentation: "Tests that jsonName works with union members.",
        protocol: railsJson,
        method: "POST",
        uri: "/post_union_with_json_name",
        body: """
            {
                "value": {
                    "_baz": "hi"
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            value: {
                baz: "hi"
            }
        }
    },
    {
        id: "RailsJsonPostUnionWithJsonNameRequest3",
        documentation: "Tests that jsonName works with union members.",
        protocol: railsJson,
        method: "POST",
        uri: "/post_union_with_json_name",
        body: """
            {
                "value": {
                    "bar": "hi"
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            value: {
                bar: "hi"
            }
        }
    }
])

apply PostUnionWithJsonName @httpResponseTests([
    {
        id: "RailsJsonPostUnionWithJsonNameResponse1",
        documentation: "Tests that jsonName works with union members.",
        protocol: railsJson,
        code: 200,
        body: """
            {
                "value": {
                    "FOO": "hi"
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            value: {
                foo: "hi"
            }
        }
    },
    {
        id: "RailsJsonPostUnionWithJsonNameResponse2",
        documentation: "Tests that jsonName works with union members.",
        protocol: railsJson,
        code: 200,
        body: """
            {
                "value": {
                    "_baz": "hi"
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            value: {
                baz: "hi"
            }
        }
    },
    {
        id: "RailsJsonPostUnionWithJsonNameResponse3",
        documentation: "Tests that jsonName works with union members.",
        protocol: railsJson,
        code: 200,
        body: """
            {
                "value": {
                    "bar": "hi"
                }
            }""",
        bodyMediaType: "application/json",
        headers: {"Content-Type": "application/json"},
        params: {
            value: {
                bar: "hi"
            }
        }
    }
])
