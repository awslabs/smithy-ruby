$version: "2"

namespace smithy.ruby.tests

@mixin
structure MixinA {
    a: String
}

@mixin
structure MixinB with [MixinA] {
    b: String
}

structure C with [MixinB] {
    c: String
}
