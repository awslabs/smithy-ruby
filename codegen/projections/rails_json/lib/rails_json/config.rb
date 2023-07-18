# frozen_string_literal: true

# WARNING ABOUT GENERATED CODE
#
# This file was code generated using smithy-ruby.
# https://github.com/awslabs/smithy-ruby
#
# WARNING ABOUT GENERATED CODE

module RailsJson
  # @!method initialize(*options)
  #   @option args [Boolean] :disable_host_prefix (false)
  #     When `true`, does not perform host prefix injection using @endpoint's hostPrefix property.
  #
  #   @option args [Boolean] :disable_request_compression (false)
  #     When set to 'true' the request body will not be compressed for supported operations.
  #
  #   @option args [String] :endpoint
  #     Endpoint of the service
  #
  #   @option args [Hearth::HTTP::Client] :http_client (Hearth::HTTP::Client.new)
  #     The HTTP Client to use for request transport.
  #
  #   @option args [Hearth::InterceptorList] :interceptors (Hearth::InterceptorList.new)
  #     A list of Interceptors to apply to the client.  Interceptors are a generic extension point that allows injecting logic at specific stages of execution within the SDK. Logic injection is done with hooks that the interceptor implements.  Hooks are either read-only or read/write. Read-only hooks allow an interceptor to read the input, transport request, transport response or output messages. Read/write hooks allow an interceptor to modify one of these messages.
  #
  #   @option args [Symbol] :log_level (:info)
  #     The default log level to use with the Logger.
  #
  #   @option args [Logger] :logger (Logger.new($stdout, level: cfg.log_level))
  #     The Logger instance to use for logging.
  #
  #   @option args [Hearth::PluginList] :plugins (Hearth::PluginList.new)
  #     A list of Plugins to apply to the client. Plugins are callables that take one argument: Config.  Plugins may modify the provided config.
  #
  #   @option args [Integer] :request_min_compression_size_bytes (10240)
  #     The minimum size bytes that triggers compression for request bodies.
  #     The value must be non-negative integer value between 0 and 10485780 bytes inclusive.
  #
  #   @option args [Hearth::Retry::Strategy] :retry_strategy (Hearth::Retry::Standard.new)
  #     Specifies which retry strategy class to use. Strategy classes
  #      may have additional options, such as max_retries and backoff strategies.
  #      Available options are:
  #      * `Retry::Standard` - A standardized set of retry rules across the AWS SDKs. This includes support for retry quotas, which limit the number of unsuccessful retries a client can make.
  #      * `Retry::Adaptive` - An experimental retry mode that includes all the functionality of `standard` mode along with automatic client side throttling.  This is a provisional mode that may change behavior in the future.
  #
  #   @option args [Boolean] :stub_responses (false)
  #     Enable response stubbing for testing. See {Hearth::ClientStubs stub_responses}.
  #
  #   @option args [Boolean] :validate_input (true)
  #     When `true`, request parameters are validated using the modeled shapes.
  #
  # @!attribute disable_host_prefix
  #   @return [Boolean]
  #
  # @!attribute disable_request_compression
  #   @return [Boolean]
  #
  # @!attribute endpoint
  #   @return [String]
  #
  # @!attribute http_client
  #   @return [Hearth::HTTP::Client]
  #
  # @!attribute interceptors
  #   @return [Hearth::InterceptorList]
  #
  # @!attribute log_level
  #   @return [Symbol]
  #
  # @!attribute logger
  #   @return [Logger]
  #
  # @!attribute plugins
  #   @return [Hearth::PluginList]
  #
  # @!attribute request_min_compression_size_bytes
  #   @return [Integer]
  #
  # @!attribute retry_strategy
  #   @return [Hearth::Retry::Strategy]
  #
  # @!attribute stub_responses
  #   @return [Boolean]
  #
  # @!attribute validate_input
  #   @return [Boolean]
  #
  Config = ::Struct.new(
    :disable_host_prefix,
    :disable_request_compression,
    :endpoint,
    :http_client,
    :interceptors,
    :log_level,
    :logger,
    :plugins,
    :request_min_compression_size_bytes,
    :retry_strategy,
    :stub_responses,
    :validate_input,
    keyword_init: true
  ) do
    include Hearth::Configuration

    private

    def validate_types!
      Hearth::Validator.validate_types!(disable_host_prefix, TrueClass, FalseClass, context: 'config[:disable_host_prefix]')
      Hearth::Validator.validate_types!(disable_request_compression, TrueClass, FalseClass, context: 'config[:disable_request_compression]')
      Hearth::Validator.validate_types!(endpoint, String, context: 'config[:endpoint]')
      Hearth::Validator.validate_types!(http_client, Hearth::HTTP::Client, context: 'config[:http_client]')
      Hearth::Validator.validate_types!(interceptors, Hearth::InterceptorList, context: 'config[:interceptors]')
      Hearth::Validator.validate_types!(log_level, Symbol, context: 'config[:log_level]')
      Hearth::Validator.validate_types!(logger, Logger, context: 'config[:logger]')
      Hearth::Validator.validate_types!(plugins, Hearth::PluginList, context: 'config[:plugins]')
      Hearth::Validator.validate_types!(request_min_compression_size_bytes, Integer, context: 'config[:request_min_compression_size_bytes]')
      Hearth::Validator.validate_types!(retry_strategy, Hearth::Retry::Strategy, context: 'config[:retry_strategy]')
      Hearth::Validator.validate_types!(stub_responses, TrueClass, FalseClass, context: 'config[:stub_responses]')
      Hearth::Validator.validate_types!(validate_input, TrueClass, FalseClass, context: 'config[:validate_input]')
    end

    def self.defaults
      @defaults ||= {
        disable_host_prefix: [false],
        disable_request_compression: [false],
        endpoint: [proc { |cfg| cfg[:stub_responses] ? 'http://localhost' : nil }],
        http_client: [proc { |cfg| Hearth::HTTP::Client.new(logger: cfg[:logger]) }],
        interceptors: [proc { Hearth::InterceptorList.new }],
        log_level: [:info],
        logger: [proc { |cfg| Logger.new($stdout, level: cfg[:log_level]) }],
        plugins: [proc { Hearth::PluginList.new }],
        request_min_compression_size_bytes: [10240],
        retry_strategy: [proc { Hearth::Retry::Standard.new }],
        stub_responses: [false],
        validate_input: [true]
      }.freeze
    end
  end
end
