# frozen_string_literal: true

# WARNING ABOUT GENERATED CODE
#
# This file was code generated using smithy-ruby.
# https://github.com/awslabs/smithy-ruby
#
# WARNING ABOUT GENERATED CODE

require 'stringio'

module WhiteLabel
  # An API client for WhiteLabel
  # See {#initialize} for a full list of supported configuration options
  # The test SDK.
  # This service should pass the tests.
  #
  # @deprecated
  #   This test SDK is not suitable
  #   for production use.
  #   Since: today
  #
  # @note
  #   This shape is unstable and may change in the future.
  #
  # @see https://www.ruby-lang.org/en/ Homepage
  #
  # @see https://www.ruby-lang.org/en/downloads/branches/ Ruby Branches
  #
  # @note
  #   This shape is meant for internal use only.
  #
  # @since today
  #
  class Client
    include Hearth::ClientStubs

    @middleware = Hearth::MiddlewareBuilder.new

    def self.middleware
      @middleware
    end

    # @param [Config] config
    #   An instance of {Config}
    #
    def initialize(config = WhiteLabel::Config.new, options = {})
      @config = config
      @middleware = Hearth::MiddlewareBuilder.new(options[:middleware])
      @stubs = Hearth::Stubbing::Stubs.new
      @retry_quota = Hearth::Retry::RetryQuota.new
      @client_rate_limiter = Hearth::Retry::ClientRateLimiter.new
    end

    # @param [Hash] params
    #   See {Types::DefaultsTestInput}.
    #
    # @return [Types::DefaultsTestOutput]
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.defaults_test(
    #     string: 'String',
    #     boxed_number: 1,
    #     default_number: 1,
    #     default_bool: false
    #   )
    #
    # @example Response structure
    #
    #   resp.data #=> Types::DefaultsTestOutput
    #   resp.data.string #=> String
    #   resp.data.boxed_number #=> Integer
    #   resp.data.default_number #=> Integer
    #   resp.data.default_bool #=> Boolean
    #
    def defaults_test(params = {}, options = {}, &block)
      stack = Hearth::MiddlewareStack.new
      input = Params::DefaultsTestInput.build(params)
      response_body = ::StringIO.new
      stack.use(Hearth::Middleware::Validate,
        validator: Validators::DefaultsTestInput,
        validate_input: @config.validate_input
      )
      stack.use(Hearth::Middleware::Build,
        builder: Builders::DefaultsTest
      )
      stack.use(Hearth::HTTP::Middleware::ContentLength)
      stack.use(Hearth::Middleware::Retry,
        retry_mode: @config.retry_mode,
        error_inspector_class: Hearth::Retry::ErrorInspector,
        retry_quota: @retry_quota,
        max_attempts: @config.max_attempts,
        client_rate_limiter: @client_rate_limiter,
        adaptive_retry_wait_to_fill: @config.adaptive_retry_wait_to_fill
      )
      stack.use(Hearth::Middleware::Parse,
        error_parser: Hearth::HTTP::ErrorParser.new(error_module: Errors, success_status: 200, errors: []),
        data_parser: Parsers::DefaultsTest
      )
      stack.use(Hearth::Middleware::Send,
        stub_responses: @config.stub_responses,
        client: Hearth::HTTP::Client.new(logger: @config.logger, http_wire_trace: options.fetch(:http_wire_trace, @config.http_wire_trace)),
        stub_class: Stubs::DefaultsTest,
        stubs: @stubs,
        params_class: Params::DefaultsTestOutput
      )
      apply_middleware(stack, options[:middleware])

      resp = stack.run(
        input: input,
        context: Hearth::Context.new(
          request: Hearth::HTTP::Request.new(url: options.fetch(:endpoint, @config.endpoint)),
          response: Hearth::HTTP::Response.new(body: response_body),
          params: params,
          logger: @config.logger,
          operation_name: :defaults_test
        )
      )
      raise resp.error if resp.error
      resp
    end

    # @param [Hash] params
    #   See {Types::EndpointOperationInput}.
    #
    # @return [Types::EndpointOperationOutput]
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.endpoint_operation()
    #
    # @example Response structure
    #
    #   resp.data #=> Types::EndpointOperationOutput
    #
    def endpoint_operation(params = {}, options = {}, &block)
      stack = Hearth::MiddlewareStack.new
      input = Params::EndpointOperationInput.build(params)
      response_body = ::StringIO.new
      stack.use(Hearth::Middleware::Validate,
        validator: Validators::EndpointOperationInput,
        validate_input: @config.validate_input
      )
      stack.use(Hearth::Middleware::HostPrefix,
        host_prefix: "foo.",
        disable_host_prefix: @config.disable_host_prefix
      )
      stack.use(Hearth::Middleware::Build,
        builder: Builders::EndpointOperation
      )
      stack.use(Hearth::HTTP::Middleware::ContentLength)
      stack.use(Hearth::Middleware::Retry,
        retry_mode: @config.retry_mode,
        error_inspector_class: Hearth::Retry::ErrorInspector,
        retry_quota: @retry_quota,
        max_attempts: @config.max_attempts,
        client_rate_limiter: @client_rate_limiter,
        adaptive_retry_wait_to_fill: @config.adaptive_retry_wait_to_fill
      )
      stack.use(Hearth::Middleware::Parse,
        error_parser: Hearth::HTTP::ErrorParser.new(error_module: Errors, success_status: 200, errors: []),
        data_parser: Parsers::EndpointOperation
      )
      stack.use(Hearth::Middleware::Send,
        stub_responses: @config.stub_responses,
        client: Hearth::HTTP::Client.new(logger: @config.logger, http_wire_trace: options.fetch(:http_wire_trace, @config.http_wire_trace)),
        stub_class: Stubs::EndpointOperation,
        stubs: @stubs,
        params_class: Params::EndpointOperationOutput
      )
      apply_middleware(stack, options[:middleware])

      resp = stack.run(
        input: input,
        context: Hearth::Context.new(
          request: Hearth::HTTP::Request.new(url: options.fetch(:endpoint, @config.endpoint)),
          response: Hearth::HTTP::Response.new(body: response_body),
          params: params,
          logger: @config.logger,
          operation_name: :endpoint_operation
        )
      )
      raise resp.error if resp.error
      resp
    end

    # @param [Hash] params
    #   See {Types::EndpointWithHostLabelOperationInput}.
    #
    # @return [Types::EndpointWithHostLabelOperationOutput]
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.endpoint_with_host_label_operation(
    #     label_member: 'labelMember' # required
    #   )
    #
    # @example Response structure
    #
    #   resp.data #=> Types::EndpointWithHostLabelOperationOutput
    #
    def endpoint_with_host_label_operation(params = {}, options = {}, &block)
      stack = Hearth::MiddlewareStack.new
      input = Params::EndpointWithHostLabelOperationInput.build(params)
      response_body = ::StringIO.new
      stack.use(Hearth::Middleware::Validate,
        validator: Validators::EndpointWithHostLabelOperationInput,
        validate_input: @config.validate_input
      )
      stack.use(Hearth::Middleware::HostPrefix,
        host_prefix: "foo.{label_member}.",
        disable_host_prefix: @config.disable_host_prefix
      )
      stack.use(Hearth::Middleware::Build,
        builder: Builders::EndpointWithHostLabelOperation
      )
      stack.use(Hearth::HTTP::Middleware::ContentLength)
      stack.use(Hearth::Middleware::Retry,
        retry_mode: @config.retry_mode,
        error_inspector_class: Hearth::Retry::ErrorInspector,
        retry_quota: @retry_quota,
        max_attempts: @config.max_attempts,
        client_rate_limiter: @client_rate_limiter,
        adaptive_retry_wait_to_fill: @config.adaptive_retry_wait_to_fill
      )
      stack.use(Hearth::Middleware::Parse,
        error_parser: Hearth::HTTP::ErrorParser.new(error_module: Errors, success_status: 200, errors: []),
        data_parser: Parsers::EndpointWithHostLabelOperation
      )
      stack.use(Hearth::Middleware::Send,
        stub_responses: @config.stub_responses,
        client: Hearth::HTTP::Client.new(logger: @config.logger, http_wire_trace: options.fetch(:http_wire_trace, @config.http_wire_trace)),
        stub_class: Stubs::EndpointWithHostLabelOperation,
        stubs: @stubs,
        params_class: Params::EndpointWithHostLabelOperationOutput
      )
      apply_middleware(stack, options[:middleware])

      resp = stack.run(
        input: input,
        context: Hearth::Context.new(
          request: Hearth::HTTP::Request.new(url: options.fetch(:endpoint, @config.endpoint)),
          response: Hearth::HTTP::Response.new(body: response_body),
          params: params,
          logger: @config.logger,
          operation_name: :endpoint_with_host_label_operation
        )
      )
      raise resp.error if resp.error
      resp
    end

    # The kitchen sink operation.
    # It is kinda useless.
    #
    # @deprecated
    #   This operation is not suitable
    #   for production use.
    #   Since: today
    #
    # @note
    #   This shape is unstable and may change in the future.
    #
    # @see https://www.ruby-lang.org/en/ Homepage
    #
    # @see https://www.ruby-lang.org/en/downloads/branches/ Ruby Branches
    #
    # @note
    #   This shape is meant for internal use only.
    #
    # @since today
    #
    # @param [Hash] params
    #   See {Types::KitchenSinkInput}.
    #
    # @option params [String] :string
    #   This is some member
    #   documentation of String.
    #
    # @option params [Struct] :struct
    #   This is some member documentation of Struct.
    #   It should override Struct's documentation.
    #
    # @option params [Union] :union
    #   This is some union documentation.
    #   It has some union members
    #
    # @return [Types::KitchenSinkOutput]
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.kitchen_sink(
    #     string: 'String',
    #     simple_enum: 'YES', # accepts ["YES", "NO", "MAYBE"]
    #     typed_enum: 'YES', # accepts ["YES", "NO", "MAYBE"]
    #     struct: {
    #       value: 'value'
    #     },
    #     document: {
    #       'nil' => nil,
    #       'number' => 123.0,
    #       'string' => 'value',
    #       'boolean' => true,
    #       'array' => [],
    #       'map' => {}
    #     },
    #     list_of_strings: [
    #       'member'
    #     ],
    #     map_of_strings: {
    #       'key' => 'value'
    #     },
    #     union: {
    #       # One of:
    #       string: 'String',
    #     }
    #   )
    #
    # @example Response structure
    #
    #   resp.data #=> Types::KitchenSinkOutput
    #   resp.data.string #=> String
    #   resp.data.simple_enum #=> String, one of ["YES", "NO", "MAYBE"]
    #   resp.data.typed_enum #=> String, one of ["YES", "NO", "MAYBE"]
    #   resp.data.struct #=> Types::Struct
    #   resp.data.struct.value #=> String
    #   resp.data.document #=> Hash,Array,String,Boolean,Numeric
    #   resp.data.list_of_strings #=> Array<String>
    #   resp.data.list_of_strings[0] #=> String
    #   resp.data.list_of_structs #=> Array<Struct>
    #   resp.data.map_of_strings #=> Hash<String, String>
    #   resp.data.map_of_strings['key'] #=> String
    #   resp.data.map_of_structs #=> Hash<String, Struct>
    #   resp.data.union #=> Types::Union, one of [String, Struct]
    #   resp.data.union.string #=> String
    #   resp.data.union.struct #=> Types::Struct
    #
    # @example Test input and output
    #
    #   # Demonstrates setting a range of input values and getting different types of outputs.
    #   #
    #   resp = client.kitchen_sink({
    #     string: "Test",
    #     struct: {
    #       value: "struct"
    #     },
    #     document: {'thing' => true, 'string' => 'hello'},
    #     list_of_strings: [
    #       "foo",
    #       "bar"
    #     ],
    #     list_of_structs: [
    #       {
    #         value: "struct1"
    #       },
    #       {
    #         value: "struct2"
    #       }
    #     ],
    #     map_of_strings: {
    #       'key1' => "value1",
    #       'key2' => "value2"
    #     },
    #     map_of_structs: {
    #       'key1' => {
    #         value: "struct1"
    #       },
    #       'key2' => {
    #         value: "struct2"
    #       }
    #     },
    #     union: {
    #       string: "union string"
    #     }
    #   })
    #
    #   # resp.to_h outputs the following:
    #   {
    #     string: "Test output",
    #     struct: {
    #       value: "struct"
    #     },
    #     document: {'thing' => true, 'string' => 'hello'},
    #     list_of_strings: [
    #       "foo",
    #       "bar"
    #     ],
    #     list_of_structs: [
    #       {
    #         value: "struct1"
    #       },
    #       {
    #         value: "struct2"
    #       }
    #     ],
    #     map_of_strings: {
    #       'key1' => "value1",
    #       'key2' => "value2"
    #     },
    #     map_of_structs: {
    #       'key1' => {
    #         value: "struct1"
    #       },
    #       'key2' => {
    #         value: "struct2"
    #       }
    #     },
    #     union: {
    #       struct: {
    #         value: "union struct"
    #       }
    #     }
    #   }
    #
    # @example Test errors
    #
    #   begin
    #     # Demonstrates an error example.
    #     #
    #     resp = client.kitchen_sink({
    #       string: "error"
    #     })
    #   rescue ApiError => e
    #     puts e.class # ClientError
    #     puts e.data.to_h
    #   end
    #
    #   # e.data.to_h outputs the following:
    #   {
    #     message: "Client error"
    #   }
    #
    def kitchen_sink(params = {}, options = {}, &block)
      stack = Hearth::MiddlewareStack.new
      input = Params::KitchenSinkInput.build(params)
      response_body = ::StringIO.new
      stack.use(Hearth::Middleware::Validate,
        validator: Validators::KitchenSinkInput,
        validate_input: @config.validate_input
      )
      stack.use(Hearth::Middleware::Build,
        builder: Builders::KitchenSink
      )
      stack.use(Hearth::HTTP::Middleware::ContentLength)
      stack.use(Hearth::Middleware::Retry,
        retry_mode: @config.retry_mode,
        error_inspector_class: Hearth::Retry::ErrorInspector,
        retry_quota: @retry_quota,
        max_attempts: @config.max_attempts,
        client_rate_limiter: @client_rate_limiter,
        adaptive_retry_wait_to_fill: @config.adaptive_retry_wait_to_fill
      )
      stack.use(Hearth::Middleware::Parse,
        error_parser: Hearth::HTTP::ErrorParser.new(error_module: Errors, success_status: 200, errors: [Errors::ClientError, Errors::ServerError]),
        data_parser: Parsers::KitchenSink
      )
      stack.use(Hearth::Middleware::Send,
        stub_responses: @config.stub_responses,
        client: Hearth::HTTP::Client.new(logger: @config.logger, http_wire_trace: options.fetch(:http_wire_trace, @config.http_wire_trace)),
        stub_class: Stubs::KitchenSink,
        stubs: @stubs,
        params_class: Params::KitchenSinkOutput
      )
      apply_middleware(stack, options[:middleware])

      resp = stack.run(
        input: input,
        context: Hearth::Context.new(
          request: Hearth::HTTP::Request.new(url: options.fetch(:endpoint, @config.endpoint)),
          response: Hearth::HTTP::Response.new(body: response_body),
          params: params,
          logger: @config.logger,
          operation_name: :kitchen_sink
        )
      )
      raise resp.error if resp.error
      resp
    end

    # @param [Hash] params
    #   See {Types::PaginatorsTestOperationInput}.
    #
    # @return [Types::PaginatorsTestOperationOutput]
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.paginators_test(
    #     next_token: 'nextToken'
    #   )
    #
    # @example Response structure
    #
    #   resp.data #=> Types::PaginatorsTestOperationOutput
    #   resp.data.next_token #=> String
    #   resp.data.items #=> Array<String>
    #   resp.data.items[0] #=> String
    #
    def paginators_test(params = {}, options = {}, &block)
      stack = Hearth::MiddlewareStack.new
      input = Params::PaginatorsTestOperationInput.build(params)
      response_body = ::StringIO.new
      stack.use(Hearth::Middleware::Validate,
        validator: Validators::PaginatorsTestOperationInput,
        validate_input: @config.validate_input
      )
      stack.use(Hearth::Middleware::Build,
        builder: Builders::PaginatorsTest
      )
      stack.use(Hearth::HTTP::Middleware::ContentLength)
      stack.use(Hearth::Middleware::Retry,
        retry_mode: @config.retry_mode,
        error_inspector_class: Hearth::Retry::ErrorInspector,
        retry_quota: @retry_quota,
        max_attempts: @config.max_attempts,
        client_rate_limiter: @client_rate_limiter,
        adaptive_retry_wait_to_fill: @config.adaptive_retry_wait_to_fill
      )
      stack.use(Hearth::Middleware::Parse,
        error_parser: Hearth::HTTP::ErrorParser.new(error_module: Errors, success_status: 200, errors: []),
        data_parser: Parsers::PaginatorsTest
      )
      stack.use(Hearth::Middleware::Send,
        stub_responses: @config.stub_responses,
        client: Hearth::HTTP::Client.new(logger: @config.logger, http_wire_trace: options.fetch(:http_wire_trace, @config.http_wire_trace)),
        stub_class: Stubs::PaginatorsTest,
        stubs: @stubs,
        params_class: Params::PaginatorsTestOperationOutput
      )
      apply_middleware(stack, options[:middleware])

      resp = stack.run(
        input: input,
        context: Hearth::Context.new(
          request: Hearth::HTTP::Request.new(url: options.fetch(:endpoint, @config.endpoint)),
          response: Hearth::HTTP::Response.new(body: response_body),
          params: params,
          logger: @config.logger,
          operation_name: :paginators_test
        )
      )
      raise resp.error if resp.error
      resp
    end

    # @param [Hash] params
    #   See {Types::PaginatorsTestWithItemsInput}.
    #
    # @return [Types::PaginatorsTestWithItemsOutput]
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.paginators_test_with_items(
    #     next_token: 'nextToken'
    #   )
    #
    # @example Response structure
    #
    #   resp.data #=> Types::PaginatorsTestWithItemsOutput
    #   resp.data.next_token #=> String
    #   resp.data.items #=> Array<String>
    #   resp.data.items[0] #=> String
    #
    def paginators_test_with_items(params = {}, options = {}, &block)
      stack = Hearth::MiddlewareStack.new
      input = Params::PaginatorsTestWithItemsInput.build(params)
      response_body = ::StringIO.new
      stack.use(Hearth::Middleware::Validate,
        validator: Validators::PaginatorsTestWithItemsInput,
        validate_input: @config.validate_input
      )
      stack.use(Hearth::Middleware::Build,
        builder: Builders::PaginatorsTestWithItems
      )
      stack.use(Hearth::HTTP::Middleware::ContentLength)
      stack.use(Hearth::Middleware::Retry,
        retry_mode: @config.retry_mode,
        error_inspector_class: Hearth::Retry::ErrorInspector,
        retry_quota: @retry_quota,
        max_attempts: @config.max_attempts,
        client_rate_limiter: @client_rate_limiter,
        adaptive_retry_wait_to_fill: @config.adaptive_retry_wait_to_fill
      )
      stack.use(Hearth::Middleware::Parse,
        error_parser: Hearth::HTTP::ErrorParser.new(error_module: Errors, success_status: 200, errors: []),
        data_parser: Parsers::PaginatorsTestWithItems
      )
      stack.use(Hearth::Middleware::Send,
        stub_responses: @config.stub_responses,
        client: Hearth::HTTP::Client.new(logger: @config.logger, http_wire_trace: options.fetch(:http_wire_trace, @config.http_wire_trace)),
        stub_class: Stubs::PaginatorsTestWithItems,
        stubs: @stubs,
        params_class: Params::PaginatorsTestWithItemsOutput
      )
      apply_middleware(stack, options[:middleware])

      resp = stack.run(
        input: input,
        context: Hearth::Context.new(
          request: Hearth::HTTP::Request.new(url: options.fetch(:endpoint, @config.endpoint)),
          response: Hearth::HTTP::Response.new(body: response_body),
          params: params,
          logger: @config.logger,
          operation_name: :paginators_test_with_items
        )
      )
      raise resp.error if resp.error
      resp
    end

    # @param [Hash] params
    #   See {Types::StreamingOperationInput}.
    #
    # @return [Types::StreamingOperationOutput]
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.streaming_operation(
    #     stream: 'stream'
    #   )
    #
    # @example Response structure
    #
    #   resp.data #=> Types::StreamingOperationOutput
    #   resp.data.stream #=> String
    #
    def streaming_operation(params = {}, options = {}, &block)
      stack = Hearth::MiddlewareStack.new
      input = Params::StreamingOperationInput.build(params)
      response_body = output_stream(options, &block)
      stack.use(Hearth::Middleware::Validate,
        validator: Validators::StreamingOperationInput,
        validate_input: @config.validate_input
      )
      stack.use(Hearth::Middleware::Build,
        builder: Builders::StreamingOperation
      )
      stack.use(Hearth::Middleware::Retry,
        retry_mode: @config.retry_mode,
        error_inspector_class: Hearth::Retry::ErrorInspector,
        retry_quota: @retry_quota,
        max_attempts: @config.max_attempts,
        client_rate_limiter: @client_rate_limiter,
        adaptive_retry_wait_to_fill: @config.adaptive_retry_wait_to_fill
      )
      stack.use(Hearth::Middleware::Parse,
        error_parser: Hearth::HTTP::ErrorParser.new(error_module: Errors, success_status: 200, errors: []),
        data_parser: Parsers::StreamingOperation
      )
      stack.use(Hearth::Middleware::Send,
        stub_responses: @config.stub_responses,
        client: Hearth::HTTP::Client.new(logger: @config.logger, http_wire_trace: options.fetch(:http_wire_trace, @config.http_wire_trace)),
        stub_class: Stubs::StreamingOperation,
        stubs: @stubs,
        params_class: Params::StreamingOperationOutput
      )
      apply_middleware(stack, options[:middleware])

      resp = stack.run(
        input: input,
        context: Hearth::Context.new(
          request: Hearth::HTTP::Request.new(url: options.fetch(:endpoint, @config.endpoint)),
          response: Hearth::HTTP::Response.new(body: response_body),
          params: params,
          logger: @config.logger,
          operation_name: :streaming_operation
        )
      )
      raise resp.error if resp.error
      resp
    end

    # @param [Hash] params
    #   See {Types::StreamingWithLengthInput}.
    #
    # @return [Types::StreamingWithLengthOutput]
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.streaming_with_length(
    #     stream: 'stream'
    #   )
    #
    # @example Response structure
    #
    #   resp.data #=> Types::StreamingWithLengthOutput
    #
    def streaming_with_length(params = {}, options = {}, &block)
      stack = Hearth::MiddlewareStack.new
      input = Params::StreamingWithLengthInput.build(params)
      response_body = ::StringIO.new
      stack.use(Hearth::Middleware::Validate,
        validator: Validators::StreamingWithLengthInput,
        validate_input: @config.validate_input
      )
      stack.use(Hearth::Middleware::Build,
        builder: Builders::StreamingWithLength
      )
      stack.use(Hearth::HTTP::Middleware::ContentLength)
      stack.use(Hearth::Middleware::Retry,
        retry_mode: @config.retry_mode,
        error_inspector_class: Hearth::Retry::ErrorInspector,
        retry_quota: @retry_quota,
        max_attempts: @config.max_attempts,
        client_rate_limiter: @client_rate_limiter,
        adaptive_retry_wait_to_fill: @config.adaptive_retry_wait_to_fill
      )
      stack.use(Hearth::Middleware::Parse,
        error_parser: Hearth::HTTP::ErrorParser.new(error_module: Errors, success_status: 200, errors: []),
        data_parser: Parsers::StreamingWithLength
      )
      stack.use(Hearth::Middleware::Send,
        stub_responses: @config.stub_responses,
        client: Hearth::HTTP::Client.new(logger: @config.logger, http_wire_trace: options.fetch(:http_wire_trace, @config.http_wire_trace)),
        stub_class: Stubs::StreamingWithLength,
        stubs: @stubs,
        params_class: Params::StreamingWithLengthOutput
      )
      apply_middleware(stack, options[:middleware])

      resp = stack.run(
        input: input,
        context: Hearth::Context.new(
          request: Hearth::HTTP::Request.new(url: options.fetch(:endpoint, @config.endpoint)),
          response: Hearth::HTTP::Response.new(body: response_body),
          params: params,
          logger: @config.logger,
          operation_name: :streaming_with_length
        )
      )
      raise resp.error if resp.error
      resp
    end

    # @param [Hash] params
    #   See {Types::WaitersTestInput}.
    #
    # @return [Types::WaitersTestOutput]
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.waiters_test(
    #     status: 'Status'
    #   )
    #
    # @example Response structure
    #
    #   resp.data #=> Types::WaitersTestOutput
    #   resp.data.status #=> String
    #
    def waiters_test(params = {}, options = {}, &block)
      stack = Hearth::MiddlewareStack.new
      input = Params::WaitersTestInput.build(params)
      response_body = ::StringIO.new
      stack.use(Hearth::Middleware::Validate,
        validator: Validators::WaitersTestInput,
        validate_input: @config.validate_input
      )
      stack.use(Hearth::Middleware::Build,
        builder: Builders::WaitersTest
      )
      stack.use(Hearth::HTTP::Middleware::ContentLength)
      stack.use(Hearth::Middleware::Retry,
        retry_mode: @config.retry_mode,
        error_inspector_class: Hearth::Retry::ErrorInspector,
        retry_quota: @retry_quota,
        max_attempts: @config.max_attempts,
        client_rate_limiter: @client_rate_limiter,
        adaptive_retry_wait_to_fill: @config.adaptive_retry_wait_to_fill
      )
      stack.use(Hearth::Middleware::Parse,
        error_parser: Hearth::HTTP::ErrorParser.new(error_module: Errors, success_status: 200, errors: []),
        data_parser: Parsers::WaitersTest
      )
      stack.use(Hearth::Middleware::Send,
        stub_responses: @config.stub_responses,
        client: Hearth::HTTP::Client.new(logger: @config.logger, http_wire_trace: options.fetch(:http_wire_trace, @config.http_wire_trace)),
        stub_class: Stubs::WaitersTest,
        stubs: @stubs,
        params_class: Params::WaitersTestOutput
      )
      apply_middleware(stack, options[:middleware])

      resp = stack.run(
        input: input,
        context: Hearth::Context.new(
          request: Hearth::HTTP::Request.new(url: options.fetch(:endpoint, @config.endpoint)),
          response: Hearth::HTTP::Response.new(body: response_body),
          params: params,
          logger: @config.logger,
          operation_name: :waiters_test
        )
      )
      raise resp.error if resp.error
      resp
    end

    # @param [Hash] params
    #   See {Types::Struct____PaginatorsTestWithBadNamesInput}.
    #
    # @return [Types::Struct____PaginatorsTestWithBadNamesOutput]
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.operation____paginators_test_with_bad_names(
    #     member___next_token: '__nextToken'
    #   )
    #
    # @example Response structure
    #
    #   resp.data #=> Types::Struct____PaginatorsTestWithBadNamesOutput
    #   resp.data.member___wrapper #=> Types::ResultWrapper
    #   resp.data.member___wrapper.member___123next_token #=> String
    #   resp.data.member___items #=> Array<String>
    #   resp.data.member___items[0] #=> String
    #
    def operation____paginators_test_with_bad_names(params = {}, options = {}, &block)
      stack = Hearth::MiddlewareStack.new
      input = Params::Struct____PaginatorsTestWithBadNamesInput.build(params)
      response_body = ::StringIO.new
      stack.use(Hearth::Middleware::Validate,
        validator: Validators::Struct____PaginatorsTestWithBadNamesInput,
        validate_input: @config.validate_input
      )
      stack.use(Hearth::Middleware::Build,
        builder: Builders::Operation____PaginatorsTestWithBadNames
      )
      stack.use(Hearth::HTTP::Middleware::ContentLength)
      stack.use(Hearth::Middleware::Retry,
        retry_mode: @config.retry_mode,
        error_inspector_class: Hearth::Retry::ErrorInspector,
        retry_quota: @retry_quota,
        max_attempts: @config.max_attempts,
        client_rate_limiter: @client_rate_limiter,
        adaptive_retry_wait_to_fill: @config.adaptive_retry_wait_to_fill
      )
      stack.use(Hearth::Middleware::Parse,
        error_parser: Hearth::HTTP::ErrorParser.new(error_module: Errors, success_status: 200, errors: []),
        data_parser: Parsers::Operation____PaginatorsTestWithBadNames
      )
      stack.use(Hearth::Middleware::Send,
        stub_responses: @config.stub_responses,
        client: Hearth::HTTP::Client.new(logger: @config.logger, http_wire_trace: options.fetch(:http_wire_trace, @config.http_wire_trace)),
        stub_class: Stubs::Operation____PaginatorsTestWithBadNames,
        stubs: @stubs,
        params_class: Params::Struct____PaginatorsTestWithBadNamesOutput
      )
      apply_middleware(stack, options[:middleware])

      resp = stack.run(
        input: input,
        context: Hearth::Context.new(
          request: Hearth::HTTP::Request.new(url: options.fetch(:endpoint, @config.endpoint)),
          response: Hearth::HTTP::Response.new(body: response_body),
          params: params,
          logger: @config.logger,
          operation_name: :operation____paginators_test_with_bad_names
        )
      )
      raise resp.error if resp.error
      resp
    end

    private

    def apply_middleware(middleware_stack, middleware)
      Client.middleware.apply(middleware_stack)
      @middleware.apply(middleware_stack)
      Hearth::MiddlewareBuilder.new(middleware).apply(middleware_stack)
    end

    def output_stream(options = {}, &block)
      return options[:output_stream] if options[:output_stream]
      return Hearth::BlockIO.new(block) if block

      ::StringIO.new
    end
  end
end
