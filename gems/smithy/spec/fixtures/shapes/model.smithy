$version: "2"

namespace smithy.ruby.tests

@trait
structure Shape {}

@shape
service ShapeService {
    version: "2018-10-31"
    operations: [Operation]
}

@shape
operation Operation {
    input: OperationInputOutput
    output: OperationInputOutput
}

structure OperationInputOutput {
    // https://smithy.io/2.0/spec/simple-types.html
    blob: Blob
    boolean: Boolean
    string: String
    byte: Byte
    short: Short
    integer: Integer
    long: Long
    float: Float
    double: Double
    bigInteger: BigInteger
    bigDecimal: BigDecimal
    timestamp: Timestamp
    document: Document
    enum: Enum
    intEnum: IntEnum

    // https://smithy.io/2.0/spec/aggregate-types.html
    list: List
    map: Map
    structure: Structure
    union: Union
}

@shape
blob Blob

@shape
boolean Boolean

@shape
string String

@shape
byte Byte

@shape
short Short

@shape
integer Integer

@shape
long Long

@shape
float Float

@shape
double Double

@shape
bigInteger BigInteger

@shape
bigDecimal BigDecimal

@shape
timestamp Timestamp

@shape
document Document

@shape
enum Enum {
    FOO = "bar"
}

@shape
intEnum IntEnum {
    BAZ = 1
}

@shape
list List {
    @shape
    member: String
}

@shape
map Map {
    @shape
    key: String
    @shape
    value: String
}

@shape
union Union {
    @shape
    string: String
    @shape
    structure: Structure
}

@shape
structure Structure {
    @shape
    member: String
}
