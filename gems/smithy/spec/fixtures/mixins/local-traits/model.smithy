$version: "2"

namespace smithy.ruby.tests

@private
@mixin(localTraits: [private])
structure PrivateMixin {
    foo: String
}

structure PublicShape with [PrivateMixin] {}
