$version: "2"

namespace smithy.ruby.tests

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
structure StructA {}

/// B
@foo(2)
@twoTrait
@mixin
structure StructB {}

/// C
@threeTrait
@mixin
structure StructC with [StructA, StructB] {}

/// D
@fourTrait
structure StructD with [StructC] {}
