$version: "2"

namespace smithy.ruby.tests

@mixin
structure UserIdentifiersMixin {
    id: String
}

structure UserDetails with [UserIdentifiersMixin] {
    alias: String
}
