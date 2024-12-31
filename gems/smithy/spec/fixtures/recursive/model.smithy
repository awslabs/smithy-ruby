$version: "2"

namespace smithy.ruby.tests

service Recursive {
    version: "1.0.0"
    operations: [Operation]
}

operation Operation {
    input: Structure
    output: Structure
}

structure Structure {
    structure: Structure
}
