$version: "2"

namespace smithy.ruby.tests

operation OperationA {
    input: Input
    output: Output
}

structure Input {}

structure Output {}

@mixin
service A {
    version: "A"
    operations: [OperationA]
}

operation OperationB {}

@mixin
service B with [A] {
    version: "B"
    rename: {
        "smithy.ruby.tests#Input": "inputB"
    }
    operations: [OperationB]
}

operation OperationC {}

service C with [B] {
    version: "C"
    rename: {
        "smithy.ruby.tests#Output": "outputC"
    }
    operations: [OperationC]
}
