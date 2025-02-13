$version: "2.0"

namespace smithy.ruby

@trait(selector: ":test(operation, structure[trait|error])")
list skipTests {
    member: skipTest
}

structure skipTest {
    @required
    id: String,
    reason: String,
    type: TestType
}

enum TestType {
    @enumValue("request")
    REQUEST,

    @enumValue("response")
    RESPONSE
}




