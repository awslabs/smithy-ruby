$version: "2"

namespace smithy.ruby.tests

@paginated(inputToken: "nextToken", outputToken: "nextToken", pageSize: "pageSize")
service ShapeService {
    version: "2018-10-31"
    resources: [
        SomeResource
    ]
    operations: [
        SomeOperation
    ]
}

operation SomeOperation {
    input: SomeOperationInput
    output: SomeOperationOutput
    errors: [SomeError]
}

@input
@documentation("This is a documentation")
structure SomeOperationInput {
    bigDecimal: BigDecimal
    bigInteger: BigInteger
    blob: Blob
    boolean: Boolean
    byte: Byte
    double: Double
    enum: SomeEnum
    float: Float
    integer: Integer
    intEnum: SomeIntEnum
    long: Long
    short: Short

    @required
    string: String

    timestamp: Timestamp
}

@output
structure SomeOperationOutput {
    list: SomeList
    map: SomeMap
    union: SomeUnion
}

enum SomeEnum {
    DOG = "dog"
    CAT = "cat"
}

@error("client")
structure SomeError {
    @required
    message: String

}

intEnum SomeIntEnum {
    FOO = 1
    BAR = 2
}

list SomeList {
    member: String
}

map SomeMap {
    key: String
    value: Integer
}

union SomeUnion {
    thing: String
}

resource SomeResource {
    identifiers: {
        someId: SomeId
    }

    properties: { someProperties: SomeProperties }
    read: ReadOperation
}

@pattern("^[A-Za-z0-9 ]+$")
string SomeId

structure SomeProperties {
    @required
    propertyNumber: Integer
}

@readonly
operation ReadOperation {
    input := for SomeResource {
        @required
        $someId
    }

    output := for SomeResource {
        @required
        @notProperty
        name: String

        @required
        $someProperties
    }

    errors: [SomeError]
}
