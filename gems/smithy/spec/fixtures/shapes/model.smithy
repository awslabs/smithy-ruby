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
    structure: Structure
    list: List
    complextList: ComplexList
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

enum Enum {
    FOO = "bar"
}

float Float

integer Integer

intEnum IntEnum {
    BAZ = 1
}

long Long

short Short

timestamp Timestamp

@documentation("This is a documentation")
@pattern("^[A-Za-z0-9 ]+$")
string String

structure Structure {
    member: String
}

list List {
    member: String
}

list ComplexList {
    member: Structure
}

map Map {
    key: String
    value: Integer
}

union Union {
    list: List
}
