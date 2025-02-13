$version: "2"

namespace smithy.ruby.tests

@mixin
@pattern("[a-zA-Z0-1]*")
string AlphaNumericMixin

@length(min: 8, max: 32)
string Username with [AlphaNumericMixin]
