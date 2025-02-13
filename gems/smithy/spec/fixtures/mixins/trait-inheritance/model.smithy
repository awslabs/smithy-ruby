$version: "2"

namespace smithy.ruby.tests

/// Generic mixin documentation.
@tags(["a"])
@mixin
structure UserInfoMixin {
    userId: String
}

structure UserSummary with [UserInfoMixin] {}
