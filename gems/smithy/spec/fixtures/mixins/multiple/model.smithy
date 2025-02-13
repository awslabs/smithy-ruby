$version: "2"

namespace smithy.ruby.tests

@mixin
structure UserIdentifiersMixin {
    id: String
}

@mixin
structure AccessDetailsMixin {
    firstAccess: Timestamp
    lastAccess: Timestamp
}

structure UserDetails with [
    UserIdentifiersMixin
    AccessDetailsMixin
] {
    alias: String
}
