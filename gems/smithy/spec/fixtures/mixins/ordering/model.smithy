$version: "2"

namespace smithy.ruby.tests

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
