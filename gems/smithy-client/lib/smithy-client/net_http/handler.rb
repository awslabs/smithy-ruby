# frozen_string_literal: true

module Smithy
  module Client
    module NetHTTP
      # The default HTTP handler for Smithy::Client. This is based on Ruby's `Net::HTTP`.
      # @api private
      class Handler < Client::Handler
        # @api private
        class TruncatedBodyError < IOError
          def initialize(bytes_expected, bytes_received)
            msg = "http response body truncated, expected #{bytes_expected} " \
                  "bytes, received #{bytes_received} bytes"
            super(msg)
          end
        end

        # @param [HandlerContext] context
        # @return [Output]
        def call(context)
          transmit(context.config, context.request, context.response)
          Output.new(context: context)
        end

        private

        # @param [Configuration] config
        # @param [HTTP::Request] req
        # @param [HTTP::Response] resp
        # @return [void]
        def transmit(config, req, resp)
          # Monkey patch default content-type set by Net::HTTP
          Thread.current[:net_http_skip_default_content_type] = true
          session(config, req) do |http|
            http.request(build_net_request(req)) do |net_resp|
              bytes_received = signal_response(net_resp, resp)
              complete_response(req, resp, bytes_received)
            end
          end
        rescue ArgumentError => e
          # Invalid verb, ArgumentError is a StandardError
          # Not retryable.
          resp.signal_error(e)
        rescue StandardError => e
          error = NetworkingError.new(e)
          resp.signal_error(error)
        ensure
          # ensure we turn off monkey patch in case of error
          Thread.current[:net_http_skip_default_content_type] = nil
        end

        def signal_response(net_resp, resp)
          status_code = net_resp.code.to_i
          headers = extract_headers(net_resp)

          bytes_received = 0
          resp.signal_headers(status_code, headers)
          net_resp.read_body do |chunk|
            bytes_received += chunk.bytesize
            resp.signal_data(chunk)
          end
          bytes_received
        end

        def complete_response(req, resp, bytes_received)
          if should_verify_bytes?(req, resp)
            verify_bytes_received(resp, bytes_received)
          else
            resp.signal_done
          end
        end

        def should_verify_bytes?(req, resp)
          req.http_method != 'HEAD' && resp.headers['content-length']
        end

        def verify_bytes_received(resp, bytes_received)
          bytes_expected = resp.headers['content-length'].to_i
          if bytes_expected == bytes_received
            resp.signal_done
          else
            error = TruncatedBodyError.new(bytes_expected, bytes_received)
            resp.signal_error(NetworkingError.new(error))
          end
        end

        # @param [Configuration] config
        # @param [HTTP::Request] req
        # @yieldparam [Net::HTTP] http
        def session(config, req, &)
          pool_for(config).session_for(req.endpoint, &)
        end

        # @param [Configuration] config
        # @return [ConnectionPool]
        def pool_for(config)
          ConnectionPool.for(pool_options(config))
        end

        # Extracts the {ConnectionPool} configuration options.
        # @param [Configuration] config
        # @return [Hash]
        def pool_options(config)
          ConnectionPool::OPTIONS.keys.each_with_object({}) do |opt, opts|
            opts[opt] = config.send(opt)
          end
        end

        # Constructs and returns a Net::HTTP::Request object from a {HTTP::Request}.
        # @param [HTTP::Request] request
        # @return [Net::HTTP::Request]
        def build_net_request(request)
          request_class = net_http_request_class(request)
          req = request_class.new(request.endpoint.request_uri, net_headers_for(request))

          # Net::HTTP adds a default Content-Type when a body is present.
          # Set the body stream when it has an unknown size or when it is > 0.
          if !request.body.respond_to?(:size) ||
             (request.body.respond_to?(:size) && request.body.size.positive?)
            req.body_stream = request.body
          end
          req
        end

        # @param [HTTP::Request] request
        # @raise [ArgumentError]
        # @return Returns a base `Net::HTTP::Request` class, e.g.,
        #  `Net::HTTP::Get`, `Net::HTTP::Post`, etc.
        def net_http_request_class(request)
          Net::HTTP.const_get(request.http_method.capitalize)
        rescue NameError
          msg = "`#{request.http_method}` is not a valid http verb"
          raise ArgumentError, msg
        end

        # Validate that fields are not trailers and return a hash of headers.
        # @param [HTTP::Request] request
        # @return [Hash<String, String>]
        def net_headers_for(request)
          # Net::HTTP adds a default header for accept-encoding (2.0.0+).
          # Setting a default empty value defeats this.
          # Removing this is necessary for most services to not break request
          # signatures as well as dynamodb crc32 checks (these fail if the
          # response is gzipped).
          # TODO: keeping this disabled to see if we can fix this
          # headers = { 'accept-encoding' => '' }
          headers = {}
          request.headers.each_pair do |key, value|
            headers[key] = value
          end
          headers
        end

        # @param [Net::HTTP::Response] response
        # @return [Hash<String, String>]
        def extract_headers(response)
          response.to_hash.transform_values(&:first)
        end
      end
    end
  end
end
