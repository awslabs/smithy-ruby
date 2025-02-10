$version: "2"

namespace smithy.ruby.tests

service Mixins {
  version: "1.0.0"
  operations: [MixinTraitPrecedenceOperation, MixinLocalTraitsOperation, OverrideTraitsOperation, MemberOrderOperation]
}

// https://smithy.io/2.0/spec/mixins.html#traits-and-mixins
operation MixinTraitPrecedenceOperation {
  input: StructD
}

@trait
integer foo

@trait
structure oneTrait {}

@trait
structure twoTrait {}

@trait
structure threeTrait {}

@trait
structure fourTrait {}

/// A
@foo(1)
@oneTrait
@mixin
structure StructA {
  memberA: String,
}

/// B
@foo(2)
@twoTrait
@mixin
structure StructB {
  memberB: String
}

/// C
@threeTrait
@mixin
structure StructC with [StructA, StructB] {
  memberC: String
}


@fourTrait
structure StructD with [StructC] {
  memberD: String
}

apply StructD @documentation("new D trait")
apply StructD$memberD @documentation("D member")

// https://smithy.io/2.0/spec/mixins.html#mixin-local-traits
operation MixinLocalTraitsOperation {
  input: PublicShape
}

@private
@mixin(localTraits: [private])
structure PrivateMixin {
  foo: String
}

structure PublicShape with [PrivateMixin] {}

// https://smithy.io/2.0/spec/mixins.html#adding-and-replacing-traits-on-copied-members
operation OverrideTraitsOperation {
  input: MyStruct
}

@trait
string tag

@mixin
structure MyMixin {
  @tag("mixin tag")
  mixinMember: String
}

structure MyStruct with [MyMixin] {}
apply MyStruct$mixinMember @tag("specific tag")


// https://smithy.io/2.0/spec/mixins.html#member-ordering
operation MemberOrderOperation {
  input: ListSomethingInput
}

@mixin
structure FilteredByNameMixin {
  nameFilter: String
}

@mixin
structure PaginatedInputMixin {
  nextToken: String
  pageSize: Integer
}

structure ListSomethingInput with [
  PaginatedInputMixin
  FilteredByNameMixin
] {
  sizeFilter: Integer
}
