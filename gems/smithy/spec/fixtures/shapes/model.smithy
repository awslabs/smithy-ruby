$version: "2"

namespace smithy.ruby.tests

@paginated(inputToken: "nextToken", outputToken: "nextToken", pageSize: "pageSize")
service ShapeService {
    version: "2018-10-31"
    operations: [
        Operation
    ]
}

@http(method: "POST", uri: "/operation")
operation Operation {
    input: OperationInputOutput
    output: OperationInputOutput
    errors: [ClientError, ServerError]
}

structure OperationInputOutput {
    // simple members
    bigDecimal: BigDecimal
    bigInteger: BigInteger
    blob: Blob
    boolean: Boolean
    byte: Byte
    document: Document
    double: Double
    enum: Enum
    float: Float
    integer: Integer
    intEnum: IntEnum
    long: Long
    short: Short
    string: String
    timestamp: Timestamp

    // member with trait
    @required
    id: String

    // complex members
    structure: OperationInputOutput
    list: List
    map: Map
    union: Union
}

bigDecimal BigDecimal

bigInteger BigInteger

blob Blob

boolean Boolean

byte Byte

document Document

double Double

float Float

long Long

short Short

timestamp Timestamp

@documentation("This is a documentation")
@pattern("^[A-Za-z0-9 ]+$")
string String

enum Enum {
    FOO = "bar"
}

intEnum IntEnum {
    BAZ = 1
}

list List {
    member: String
}

map Map {
    key: String
    value: Integer
}

union Union {
    list: List
}

@error("client")
structure ClientError {
    @required
    message: String
}

@error("server")
@retryable(throttling: true)
structure ServerError {}

