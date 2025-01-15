$version: "2"

namespace smithy.ruby.tests

service Errors {
    operations: [Operation]
    errors: [ServiceError]
}

operation Operation {
    errors: [
        ClientError
        ClientRetryableError
        ClientThrottlingError
        ServerError
        ServerRetryableError
        ServerThrottlingError
    ]
}

@error("client")
structure ClientError {}

@error("client")
@retryable
structure ClientRetryableError {}

@error("client")
@retryable(throttling: true)
structure ClientThrottlingError {}

@error("server")
structure ServerError {}

@error("server")
@retryable
structure ServerRetryableError {}

@error("server")
@retryable(throttling: true)
structure ServerThrottlingError {}

/// This is a service error.
/// It is raised sometimes.
@error("server")
structure ServiceError {
    message: String
    /// This is a structure in a service error.
    /// It sometimes has data.
    structure: Structure
}

structure Structure {
    value: String
}