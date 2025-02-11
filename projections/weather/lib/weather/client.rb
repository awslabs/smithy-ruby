# frozen_string_literal: true

# This is generated code!

require_relative 'plugins/endpoint'
require_relative 'plugins/protocol'
require 'smithy-client/plugins/logging'
require 'smithy-client/plugins/net_http'
require 'smithy-client/plugins/param_validator'
require 'smithy-client/plugins/raise_response_errors'
require 'smithy-client/plugins/response_target'

module Weather
  # An API client for Weather.
  # See {#initialize} for a full list of supported configuration options.
  class Client < Smithy::Client::Base
    self.schema = Shapes::SCHEMA

    add_plugin(Weather::Plugins::Endpoint)
    add_plugin(Weather::Plugins::Protocol)
    add_plugin(Smithy::Client::Plugins::Logging)
    add_plugin(Smithy::Client::Plugins::NetHTTP)
    add_plugin(Smithy::Client::Plugins::ParamValidator)
    add_plugin(Smithy::Client::Plugins::RaiseResponseErrors)
    add_plugin(Smithy::Client::Plugins::ResponseTarget)

    # @overload initialize(options)
    #   @option options [String] :endpoint
    #    Custom Endpoint
    #   @option options [Weather::EndpointProvider] :endpoint_provider
    #    The endpoint provider used to resolve endpoints. Any object that responds to
    #    `#resolve_endpoint(parameters)`.
    #   @option options [String] :http_ca_file
    #    The path to a CA certification file in PEM format. Defaults to `nil` which uses
    #    the Net::HTTP default value.
    #   @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-ca_file
    #   @option options [String] :http_ca_path
    #    The path of to CA directory containing certification files in PEM format. Defaults to
    #    `nil` which uses the Net::HTTP default value.
    #    @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-ca_path
    #   @option options [OpenSSL::X509::Certificate] :http_cert
    #    Sets the OpenSSL::X509::Certificate object to be used for client certification. Defaults
    #    to `nil` which uses the Net::HTTP default value.
    #    @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-cert
    #   @option options [OpenSSL::X509::Store] :http_cert_store
    #    Sets the OpenSSL::X509::Store to be used for verifying peer certificate. Defaults to
    #    `nil` which uses the Net::HTTP default value.
    #    @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-cert_store
    #   @option options [Numeric] :http_continue_timeout
    #    Sets the continue timeout value, which is the number of seconds to wait for an
    #    expected 100 Continue response. If the HTTP object does not receive a response
    #    in this many seconds it sends the request body. Defaults to `nil` which uses the
    #    Net::HTTP default value.
    #    @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-continue_timeout
    #   @option options [Boolean] :http_debug_output
    #    When `true`, Net::HTTP debug output will be sent to the configured logger.
    #    @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#method-i-set_debug_output
    #   @option options [Numeric] :http_keep_alive_timeout
    #    The number of seconds to keep the connection open after a request is sent. If a
    #    new request is made during the given interval, the still-open connection is used;
    #    otherwise the connection will have been closed and a new connection is opened.
    #    Defaults to `nil` which uses the Net::HTTP default value.
    #    @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-keep_alive_timeout
    #   @option options [OpenSSL::PKey::RSA, OpenSSL::PKey::DSA] :http_key
    #    Sets the OpenSSL::PKey object to be used for client private key. Defaults to `nil` which
    #    uses the Net::HTTP default value.
    #    @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-key
    #   @option options [Numeric] :http_open_timeout
    #    The number of seconds to wait for a connection to open. If the connection is not
    #    made in the given interval, an exception is raised. Defaults to `nil` which uses
    #    the Net::HTTP default value.
    #    @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-open_timeout
    #   @option options [URI::HTTP, String] :http_proxy
    #    A proxy to send requests through. Formatted like 'http://proxy.com:123'.
    #   @option options [Numeric] :http_read_timeout
    #    The number of seconds to wait for one block to be read (via one read(2) call).
    #    Defaults to `nil` which uses the Net::HTTP default value.
    #    @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-read_timeout
    #   @option options [Numeric] :http_ssl_timeout
    #    Sets the SSL timeout seconds. Defaults to `nil` which uses the Net::HTTP default value.
    #    @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-ssl_timeout
    #   @option options [Integer] :http_verify_mode (OpenSSL::SSL::VERIFY_PEER)
    #    Sets the verify mode for SSL. Defaults to `OpenSSL::SSL::VERIFY_PEER`.
    #    @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-verify_mode
    #   @option options [Numeric] :http_write_timeout
    #    The number of seconds to wait for one block to be written (via one write(2) call).
    #    Defaults to `nil` which uses the Net::HTTP default value.
    #    @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-write_timeout
    #   @option options [Symbol] :log_level (info)
    #    The log level to send messages to the logger at.
    #   @option options [Logger] :logger
    #    The Logger instance to send log messages to. If this option is not set,
    #    logging is disabled.
    #   @option options [Boolean] :raise_response_errors (true)
    #    When `true`, response errors are raised. When `false`, the error is placed on the
    #    output in the {Smithy::Client::Output#error error accessor}.
    #   @option options [Boolean] :validate_params (true)
    #    When `true`, request parameters are validated before sending the request.
    def initialize(*args)
      super
    end

    # @example Request syntax with placeholder values
    #   params = {
    #     city_id: "CityId", # required
    #   }
    #   options = {}
    #   output = client.get_city(params, options)
    # @example Response structure with placeholder values
    #   output.to_h #=>
    #   {
    #     name: "String", # required
    #     coordinates: { # required
    #       latitude: 1.0, # required
    #       longitude: 1.0, # required
    #     }
    #   }
    def get_city(params = {}, options = {})
      input = build_input(:get_city, params)
      input.send_request(options)
    end

    # @example Request syntax with placeholder values
    #   params = {}
    #   options = {}
    #   output = client.get_current_time(params, options)
    # @example Response structure with placeholder values
    #   output.to_h #=>
    #   {
    #     time: Time.now, # required
    #   }
    def get_current_time(params = {}, options = {})
      input = build_input(:get_current_time, params)
      input.send_request(options)
    end

    # @example Request syntax with placeholder values
    #   params = {
    #     city_id: "CityId", # required
    #   }
    #   options = {}
    #   output = client.get_forecast(params, options)
    # @example Response structure with placeholder values
    #   output.to_h #=>
    #   {
    #     chance_of_rain: 1.0
    #   }
    def get_forecast(params = {}, options = {})
      input = build_input(:get_forecast, params)
      input.send_request(options)
    end

    # @example Request syntax with placeholder values
    #   params = {
    #     next_token: "String",
    #     page_size: 1
    #   }
    #   options = {}
    #   output = client.list_cities(params, options)
    # @example Response structure with placeholder values
    #   output.to_h #=>
    #   {
    #     next_token: "String",
    #     items: [ # required
    #       {
    #         city_id: "CityId", # required
    #         name: "String", # required
    #       }
    #     ]
    #   }
    def list_cities(params = {}, options = {})
      input = build_input(:list_cities, params)
      input.send_request(options)
    end

    private

    def build_input(operation_name, params)
      handlers = @handlers.for(operation_name)
      context = Smithy::Client::HandlerContext.new(
        operation_name: operation_name,
        operation: config.schema.operation(operation_name),
        client: self,
        params: params,
        config: config
      )
      context[:gem_name] = 'weather'
      context[:gem_version] = '1.0.0'
      Smithy::Client::Input.new(handlers: handlers, context: context)
    end
  end
end
