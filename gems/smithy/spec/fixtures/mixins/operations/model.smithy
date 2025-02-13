$version: "2"

namespace smithy.ruby.tests

@mixin
operation ValidatedOperation {
    errors: [ValidationError]
}

@error("client")
structure ValidationError {}

operation GetUsername with [ValidatedOperation] {
    input := {
        id: String
    }
    output := {
        name: String
    }
    errors: [NotFoundError]
}

@error("client")
structure NotFoundError {}
