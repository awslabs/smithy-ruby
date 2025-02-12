$version: "2"

namespace smithy.ruby.tests

structure Foo {
    value: String
    structure: Foo
    structure2: Bar
}

structure Bar {
    value: String
    structure: Foo
    structure2: Bar
}
