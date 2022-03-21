# Hearth

## What is it
Hearth is a base dependency for Ruby SDK API Clients built by
[smithy-ruby][smithy-ruby] using a [Smithy][Smithy] model. Hearth provides an
implementation of the components necessary to make requests and handle responses
from a service. Hearth is only intended to be used with clients that were code
generated using Smithy, but it may be used for any service client
implementation.

## Components
Hearth contains reusable components that are used by code generated Ruby SDKs.
Such components include, but are not limited to: transport clients, request and
response objects, middleware, serialization and deserialization helpers for JSON
and XML, error classes and parsers, stubbing modules, etc.

### Middleware
Hearth uses middleware to handle the request and response cycle for service
operations. Middleware is used for building requests, parsing responses, sending
requests, and everything in-between.

#### Interface
All middleware must conform to the same interface. Middleware must have an
`#initialize` method that takes `app` as a positional parameter and any number
of keyword arguments that the middleware will use. Middleware must also have a
`#call` method that takes `input` (a Struct) and `context` (`Hearth::Context`)
as positional parameters. The method must return the result of the next
middleware call (`@app.call(input, context)`).

```ruby
def initialize(app, some_option:)
  @app = app
  ...
end

def call(input, context)
  # do a thing
  # inspect or modify input or context.request
  output = @app.call(input, context)
  # do another thing
  # inspect or modify output or context.response
  output
end
```

#### Context
Middleware shares a context object (`Hearth::Context`) which allows middleware
to share state. The context object contains a logger, the request, the response,
the original params, the operation name, and a metadata hash for arbitrary data.

#### List of Middleware

Hearth implements the following protocol agnostic Middleware interfaces:

* `Build`: Populates a protocol specific request object using input with a
   builder class. The builder class must respond to `.build` and take the
   request object as a positional parameter and `input` as a keyword argument.
* `Parse`: Populates `Hearth::Output` using a protocol specific response
   object with both a data parser and error parser class. The data parser must
   respond to `.parse` and take the response object as a positional parameter
   and `data` as a keyword argument. The error parser is a protocol specific
   parser. For HTTP, Hearth includes `Hearth::HTTP::ErrorParser` that can be
   used with service information to determine errors and parse its data.
* `Retry`: Retries any networking errors or modeled retry-able errors. It can be
   configured with `max_attempts` and `max_delay`.
* `Send`: Handles sending a protocol specific request and populating a protocol
   specific response object using a client. It is configured with the `client`
   keyword argument. A client implementation must implement `#transmit` method
   that takes `request` and `response` keyword arguments. It can also stub
   responses instead of sending network requests. Stubbing is configured with
   three keyword arguments:
   * `stub_responses`: Configuration for enabling or disabling stubbing. If
     enabled at runtime, network requests are not sent.
   * `stub_class`: A class that can populate a protocol specific response using
     stubbed data. The class must respond to `.stub` that takes a response
     object as a positional parameter and a `stub` as a keyword argument.
   * `stubs`: An instance of `Hearth::Stubbing::Stubs` that contains stub
     data.
* `Validate`: Validates Ruby types from input against the modeled types using a
   validator class. It can disabled using the `validate_input` configuration.
   The validator class must respond to `.validate!` and take `input` as a
   positional parameter and `context` as a keyword argument. The context is used
   for printing sane error messages for where the validationfailed.

For HTTP, Hearth implements a `ContentLength` middleware for setting the
`Content-Length` header to the body's size.

#### Middleware Usage Example

For each client operation invocation, a middleware stack is created and
middleware is added to it in a specific order. The middleware stack is then run
in a reverse order. An example code generated Client operation is as follows:

```ruby
def get_high_score(params = {}, options = {})
  # Creates the stack.
  stack = Hearth::MiddlewareStack.new
  input = Params::GetHighScoreInput.build(params)
  # This middleware will build a request.
  # Takes a builder object as an argument.
  stack.use(
    Hearth::Middleware::Build,
    builder: Builders::GetHighScore
  )
  # This middleware will parse a response.
  # Takes a data parser and error parser as arguments.
  stack.use(
    Hearth::Middleware::Parse,
    error_parser: Hearth::HTTP::ErrorParser.new(
      error_module: Errors,
      success_status: 200, errors: [],
      error_code_fn: Errors.method(:error_code)),
    data_parser: Parsers::GetHighScore
  )
  # This middleware sends the request.
  # Takes a protocol specific client and stubbing information as arguments.
  stack.use(
    Hearth::Middleware::Send,
    client: Hearth::HTTP::Client.new(
      logger: @logger,
      http_wire_trace: @http_wire_trace
    ),
    stub_responses: options.fetch(:stub_responses, @stub_responses),
    stub_class: Stubs::GetHighScore,
    stubs: @stubs
  )
  # Merges any dynamic/runtime middleware into the stack
  apply_middleware(stack, options[:middleware])
  # Runs the middleware stack using input and context.
  # The request is populated using the builder.
  # The request is sent using the protocol client.
  # The response is populated using the parser.
  # The output is returned.
  resp = stack.run(
    input: input,
    context: Hearth::Context.new(
      request: Hearth::HTTP::Request.new(
        url: options.fetch(:endpoint, @endpoint)
      ),
      response: Hearth::HTTP::Response.new,
      params: params,
      logger: @logger,
      operation_name: :get_high_score
    )
  )
  raise resp.error if resp.error
  resp.data
end
```

### Protocol Clients

#### HTTP
Hearth includes a basic HTTP client implemented on `Net::HTTP`. In Smithy
code generated clients, it is used by `Hearth::Middleware::Send` by default.
It can be configured to debug wire trace information using a configured logger,
as well as configure proxy and SSL related values.

#### HTTP 2
Not yet supported.

### Request and Response objects
Hearth includes request and response objects for protocols, such as
`Hearth::HTTP::Request` and `Hearth::HTTP::Response`. These objects contain
raw HTTP request and response information, such as a URL, headers, body, status,
etc. These values can only be accessed via `Hearth::Context` in middleware.

### XML and JSON Protocols
Hearth includes serialization and deserialization helpers for JSON and XML
based protocols. `Hearth::JSON` can be used to dump and load JSON strings and
`Hearth::XML` can be used to build XML strings and parse XML documents.

### Stubbing
Hearth includes a `Hearth::Stubbing::Stubs` class that can hold stub data
used by the client's `stub_responses` method. The `stub_responses` method is
defined in the `Hearth::Stubbing::ClientStubs` module. To support stubbing,
generated SDK clients must include this module and include protocol specific
stub classes which serialize stub data into a response.

### Errors
Hearth defines a base `Hearth::ApiError` that can be inherited by protocol
specific errors such as `Hearth::HTTP::ApiError`. Code generated clients will
inherit from these protocol specific error classes.

## License

This project is licensed under the Apache-2.0 License.

<!--- Links -->
[smithy-ruby]: https://github.com/awslabs/smithy-ruby
[Smithy]: https://awslabs.github.io/smithy/
