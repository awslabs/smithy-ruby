$version: "2"

namespace smithy.ruby.tests

@mixin
structure A1 {
    @private
    a: String
}

@mixin
structure A2 {
    @required
    a: String
}

structure Valid with [A1, A2] {}
