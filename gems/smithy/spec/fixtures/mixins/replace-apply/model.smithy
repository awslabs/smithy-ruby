$version: "2"

namespace smithy.ruby.tests

@mixin
structure MyMixin {
    /// Generic docs
    mixinMember: String
}

structure MyStruct with [MyMixin] {}
apply MyStruct$mixinMember @documentation("Specific docs")
