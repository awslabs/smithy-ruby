$version: "2"

namespace smithy.ruby.tests

/// Generic mixin documentation.
@tags(["a"])
@mixin
structure UserInfoMixin {
    userId: String
}

/// Specific documentation
@tags(["replaced-tags"])
structure UserSummary with [UserInfoMixin] {}
