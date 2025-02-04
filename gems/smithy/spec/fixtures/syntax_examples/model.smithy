$version: "2"

namespace smithy.ruby.tests

service SyntaxExamples {
    operations: [Operation]
}

operation Operation {
    input: OperationInputOutput
    output: OperationInputOutput
}

structure OperationInputOutput {
    // https://smithy.io/2.0/spec/simple-types.html
    blob: Blob,
    @required
    streamingBlob: StreamingBlob,
    boolean: Boolean,
    string: String,
    byte: Byte,
    short: Short,
    integer: Integer,
    long: Long,
    float: Float,
    double: Double,
    bigInteger: BigInteger,
    bigDecimal: BigDecimal,
    timestamp: Timestamp,
    document: Document,
    enum: Enum,
    intEnum: IntEnum,

    // https://smithy.io/2.0/spec/aggregate-types.html
    simpleList: SimpleList,
    complexList: ComplexList,
    simpleMap: SimpleMap,
    complexMap: ComplexMap,
    structure: Structure,
    union: Union
}

@streaming
blob StreamingBlob

enum Enum {
    VALUE
}

intEnum IntEnum {
    VALUE = 0
}

structure Structure {
    member: String
}

list SimpleList {
    member: String
}

list ComplexList {
    member: Structure
}

map SimpleMap {
    key: String,
    value: String
}

map ComplexMap {
    key: String,
    value: Structure
}

union Union {
    string: String,
    structure: Structure
    simpleList: SimpleList
    simpleMap: SimpleMap
    complexList: ComplexList
    complexMap: ComplexMap
}
