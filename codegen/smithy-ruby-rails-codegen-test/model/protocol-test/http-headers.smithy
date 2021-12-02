// This file defines test cases that test HTTP header bindings.
// See: https://awslabs.github.io/smithy/1.0/spec/http.html#httpheader-trait

$version: "1.0"

namespace smithy.ruby.protocoltests.railsjson

use smithy.ruby.protocols#railsJson
use aws.protocoltests.shared#BooleanList
use aws.protocoltests.shared#DateTime
use aws.protocoltests.shared#EpochSeconds
use aws.protocoltests.shared#FooEnum
use aws.protocoltests.shared#FooEnumList
use aws.protocoltests.shared#HttpDate
use aws.protocoltests.shared#IntegerList
use aws.protocoltests.shared#StringList
use aws.protocoltests.shared#StringSet
use aws.protocoltests.shared#TimestampList
use smithy.test#httpRequestTests
use smithy.test#httpResponseTests

/// The example tests how requests and responses are serialized when there is
/// no input or output payload but there are HTTP header bindings.
@http(uri: "/InputAndOutputWithHeaders", method: "POST")
operation InputAndOutputWithHeaders {
    input: InputAndOutputWithHeadersIO,
    output: InputAndOutputWithHeadersIO
}

apply InputAndOutputWithHeaders @httpRequestTests([
    {
        id: "RailsJsonInputAndOutputWithStringHeaders",
        documentation: "Tests requests with string header bindings",
        protocol: railsJson,
        method: "POST",
        uri: "/InputAndOutputWithHeaders",
        headers: {
            "X-String": "Hello",
            "X-StringList": "a, b, c",
            "X-StringSet": "a, b, c"
        },
        body: "",
        params: {
            headerString: "Hello",
            headerStringList: ["a", "b", "c"],
            headerStringSet: ["a", "b", "c"],
        }
    },
    {
        id: "RailsJsonInputAndOutputWithNumericHeaders",
        documentation: "Tests requests with numeric header bindings",
        protocol: railsJson,
        method: "POST",
        uri: "/InputAndOutputWithHeaders",
        headers: {
            "X-Byte": "1",
            "X-Short": "123",
            "X-Integer": "123",
            "X-Long": "123",
            "X-Float": "1.1",
            "X-Double": "1.1",
            "X-IntegerList": "1, 2, 3",
        },
        body: "",
        params: {
            headerByte: 1,
            headerShort: 123,
            headerInteger: 123,
            headerLong: 123,
            headerFloat: 1.1,
            headerDouble: 1.1,
            headerIntegerList: [1, 2, 3],
        }
    },
    {
        id: "RailsJsonInputAndOutputWithBooleanHeaders",
        documentation: "Tests requests with boolean header bindings",
        protocol: railsJson,
        method: "POST",
        uri: "/InputAndOutputWithHeaders",
        headers: {
            "X-Boolean1": "true",
            "X-Boolean2": "false",
            "X-BooleanList": "true, false, true"
        },
        body: "",
        params: {
            headerTrueBool: true,
            headerFalseBool: false,
            headerBooleanList: [true, false, true]
        }
    },
    {
        id: "RailsJsonInputAndOutputWithEnumHeaders",
        documentation: "Tests requests with enum header bindings",
        protocol: railsJson,
        method: "POST",
        uri: "/InputAndOutputWithHeaders",
        headers: {
            "X-Enum": "Foo",
            "X-EnumList": "Foo, Bar, Baz"
        },
        body: "",
        params: {
            headerEnum: "Foo",
            headerEnumList: ["Foo", "Bar", "Baz"],
        }
    },
])

apply InputAndOutputWithHeaders @httpResponseTests([
    {
        id: "RailsJsonInputAndOutputWithStringHeaders",
        documentation: "Tests responses with string header bindings",
        protocol: railsJson,
        code: 200,
        headers: {
            "X-String": "Hello",
            "X-StringList": "a, b, c",
            "X-StringSet": "a, b, c"
        },
        body: "",
        params: {
            headerString: "Hello",
            headerStringList: ["a", "b", "c"],
            headerStringSet: ["a", "b", "c"],
        }
    },
    {
        id: "RailsJsonInputAndOutputWithNumericHeaders",
        documentation: "Tests responses with numeric header bindings",
        protocol: railsJson,
        code: 200,
        headers: {
            "X-Byte": "1",
            "X-Short": "123",
            "X-Integer": "123",
            "X-Long": "123",
            "X-Float": "1.1",
            "X-Double": "1.1",
            "X-IntegerList": "1, 2, 3",
        },
        body: "",
        params: {
            headerByte: 1,
            headerShort: 123,
            headerInteger: 123,
            headerLong: 123,
            headerFloat: 1.1,
            headerDouble: 1.1,
            headerIntegerList: [1, 2, 3],
        }
    },
    {
        id: "RailsJsonInputAndOutputWithBooleanHeaders",
        documentation: "Tests responses with boolean header bindings",
        protocol: railsJson,
        code: 200,
        headers: {
            "X-Boolean1": "true",
            "X-Boolean2": "false",
            "X-BooleanList": "true, false, true"
        },
        body: "",
        params: {
            headerTrueBool: true,
            headerFalseBool: false,
            headerBooleanList: [true, false, true]
        }
    },
    {
        id: "RailsJsonInputAndOutputWithEnumHeaders",
        documentation: "Tests responses with enum header bindings",
        protocol: railsJson,
        code: 200,
        headers: {
            "X-Enum": "Foo",
            "X-EnumList": "Foo, Bar, Baz"
        },
        body: "",
        params: {
            headerEnum: "Foo",
            headerEnumList: ["Foo", "Bar", "Baz"],
        }
    },
])

structure InputAndOutputWithHeadersIO {
    @httpHeader("X-String")
    headerString: String,

    @httpHeader("X-Byte")
    headerByte: Byte,

    @httpHeader("X-Short")
    headerShort: Short,

    @httpHeader("X-Integer")
    headerInteger: Integer,

    @httpHeader("X-Long")
    headerLong: Long,

    @httpHeader("X-Float")
    headerFloat: Float,

    @httpHeader("X-Double")
    headerDouble: Double,

    @httpHeader("X-Boolean1")
    headerTrueBool: Boolean,

    @httpHeader("X-Boolean2")
    headerFalseBool: Boolean,

    @httpHeader("X-StringList")
    headerStringList: StringList,

    @httpHeader("X-StringSet")
    headerStringSet: StringSet,

    @httpHeader("X-IntegerList")
    headerIntegerList: IntegerList,

    @httpHeader("X-BooleanList")
    headerBooleanList: BooleanList,

    @httpHeader("X-TimestampList")
    headerTimestampList: TimestampList,

    @httpHeader("X-Enum")
    headerEnum: FooEnum,

    @httpHeader("X-EnumList")
    headerEnumList: FooEnumList,
}

/// Null and empty headers are not sent over the wire.
@readonly
@http(uri: "/NullAndEmptyHeadersClient", method: "GET")
@tags(["client-only"])
operation NullAndEmptyHeadersClient {
    input: NullAndEmptyHeadersIO,
    output: NullAndEmptyHeadersIO
}

apply NullAndEmptyHeadersClient @httpRequestTests([
    {
        id: "RailsJsonNullAndEmptyHeaders",
        documentation: "Do not send null values, empty strings, or empty lists over the wire in headers",
        protocol: railsJson,
        method: "GET",
        uri: "/NullAndEmptyHeadersClient",
        forbidHeaders: ["X-A", "X-B", "X-C"],
        body: "",
        params: {
            a: null,
            b: "",
            c: [],
        },
        appliesTo: "client",
    },
])

/// Null and empty headers are not sent over the wire.
@readonly
@http(uri: "/NullAndEmptyHeadersServer", method: "GET")
@tags(["server-only"])
operation NullAndEmptyHeadersServer {
    input: NullAndEmptyHeadersIO,
    output: NullAndEmptyHeadersIO
}

apply NullAndEmptyHeadersServer @httpResponseTests([
    {
        id: "RailsJsonNullAndEmptyHeaders",
        documentation: "Do not send null or empty headers",
        protocol: railsJson,
        code: 200,
        forbidHeaders: ["X-A", "X-B", "X-C"],
        body: "",
        params: {
            a: null,
            b: "",
            c: [],
        },
        appliesTo: "server",
    },
])

structure NullAndEmptyHeadersIO {
    @httpHeader("X-A")
    a: String,

    @httpHeader("X-B")
    b: String,

    @httpHeader("X-C")
    c: StringList,
}

/// This example tests how timestamp request and response headers are serialized.
@http(uri: "/TimestampFormatHeaders", method: "POST")
operation TimestampFormatHeaders {
    input: TimestampFormatHeadersIO,
    output: TimestampFormatHeadersIO
}

apply TimestampFormatHeaders @httpRequestTests([
    {
        id: "RailsJsonTimestampFormatHeaders",
        documentation: "Tests how timestamp request headers are serialized",
        protocol: railsJson,
        method: "POST",
        uri: "/TimestampFormatHeaders",
        headers: {
            "X-memberEpochSeconds": "1576540098",
            "X-memberHttpDate": "Mon, 16 Dec 2019 23:48:18 GMT",
            "X-memberDateTime": "2019-12-16T23:48:18.000Z",
            "X-defaultFormat": "Mon, 16 Dec 2019 23:48:18 GMT",
            "X-targetEpochSeconds": "1576540098",
            "X-targetHttpDate": "Mon, 16 Dec 2019 23:48:18 GMT",
            "X-targetDateTime": "2019-12-16T23:48:18.000Z",
        },
        body: "",
        params: {
            memberEpochSeconds: 1576540098,
            memberHttpDate: 1576540098,
            memberDateTime: 1576540098,
            defaultFormat: 1576540098,
            targetEpochSeconds: 1576540098,
            targetHttpDate: 1576540098,
            targetDateTime: 1576540098,
        }
    },
])

apply TimestampFormatHeaders @httpResponseTests([
    {
        id: "RailsJsonTimestampFormatHeaders",
        documentation: "Tests how timestamp response headers are serialized",
        protocol: railsJson,
        code: 200,
        headers: {
            "X-memberEpochSeconds": "1576540098",
            "X-memberHttpDate": "Mon, 16 Dec 2019 23:48:18 GMT",
            "X-memberDateTime": "2019-12-16T23:48:18.000Z",
            "X-defaultFormat": "Mon, 16 Dec 2019 23:48:18 GMT",
            "X-targetEpochSeconds": "1576540098",
            "X-targetHttpDate": "Mon, 16 Dec 2019 23:48:18 GMT",
            "X-targetDateTime": "2019-12-16T23:48:18.000Z",
        },
        body: "",
        params: {
            memberEpochSeconds: 1576540098,
            memberHttpDate: 1576540098,
            memberDateTime: 1576540098,
            defaultFormat: 1576540098,
            targetEpochSeconds: 1576540098,
            targetHttpDate: 1576540098,
            targetDateTime: 1576540098,
        }
    },
])

structure TimestampFormatHeadersIO {
    @httpHeader("X-memberEpochSeconds")
    @timestampFormat("epoch-seconds")
    memberEpochSeconds: Timestamp,

    @httpHeader("X-memberHttpDate")
    @timestampFormat("http-date")
    memberHttpDate: Timestamp,

    @httpHeader("X-memberDateTime")
    @timestampFormat("date-time")
    memberDateTime: Timestamp,

    @httpHeader("X-defaultFormat")
    defaultFormat: Timestamp,

    @httpHeader("X-targetEpochSeconds")
    targetEpochSeconds: EpochSeconds,

    @httpHeader("X-targetHttpDate")
    targetHttpDate: HttpDate,

    @httpHeader("X-targetDateTime")
    targetDateTime: DateTime,
}

/// This example ensures that mediaType strings are base64 encoded in headers.
@readonly
@http(uri: "/MediaTypeHeader", method: "GET")
operation MediaTypeHeader {
    input: MediaTypeHeaderInput,
    output: MediaTypeHeaderOutput
}

apply MediaTypeHeader @httpRequestTests([
    {
        id: "RailsJsonMediaTypeHeaderInputBase64",
        documentation: "Headers that target strings with a mediaType are base64 encoded",
        protocol: railsJson,
        method: "GET",
        uri: "/MediaTypeHeader",
        headers: {
            "X-Json": "dHJ1ZQ=="
        },
        body: "",
        params: {
            json: "true"
        }
    },
])

apply MediaTypeHeader @httpResponseTests([
    {
        id: "RailsJsonMediaTypeHeaderOutputBase64",
        documentation: "Headers that target strings with a mediaType are base64 encoded",
        protocol: railsJson,
        code: 200,
        headers: {
            "X-Json": "dHJ1ZQ=="
        },
        body: "",
        params: {
            json: "true"
        }
    },
])

structure MediaTypeHeaderInput {
    @httpHeader("X-Json")
    json: JsonValue,
}

structure MediaTypeHeaderOutput {
    @httpHeader("X-Json")
    json: JsonValue,
}

@mediaType("application/json")
string JsonValue