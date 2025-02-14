# frozen_string_literal: true

require 'stringio'

module Smithy
  module Client
    module HTTP
      # Represents an HTTP Response.
      class Response
        # @option options [Integer] :status_code (0)
        # @option options [Headers] :headers (Headers.new)
        # @option options [IO] :body (StringIO.new)
        def initialize(options = {})
          @status_code = options[:status_code] || 0
          @headers = options[:headers] || Headers.new
          @body = options[:body] || StringIO.new
          @listeners = Hash.new { |h, k| h[k] = [] }

          @complete = false
          @done = nil
          @error = nil
        end

        # @return [Integer]
        attr_accessor :status_code

        # @return [Headers]
        attr_accessor :headers

        # @return [IO, StringIO]
        attr_reader :body

        # @return [StandardError, nil]
        attr_reader :error

        # @param [#read, #size, #rewind] io
        def body=(io)
          @body =
            case io
            when nil then StringIO.new('')
            when String then StringIO.new(io)
            else io
            end
        end

        # @param [Integer] status_code
        # @param [Hash<String, String>] headers
        def signal_headers(status_code, headers)
          @status_code = status_code
          @headers = Headers.new(headers)
          emit(:headers, @status_code, @headers)
        end

        # @param [string] chunk
        def signal_data(chunk)
          return if chunk == ''

          @body.write(chunk)
          emit(:data, chunk)
        end

        # Completes the http response.
        #
        # @example Completing the response in a single call
        #
        #     http_response.signal_done(
        #       status_code: 200,
        #       headers: {},
        #       body: ''
        #     )
        #
        # @example Complete the response in parts
        #
        #     # signal headers straight-way
        #     http_response.signal_headers(200, {})
        #
        #     # signal data as it is received from the socket
        #     http_response.signal_data("...")
        #     http_response.signal_data("...")
        #     http_response.signal_data("...")
        #
        #     # signal done once the body data is all written
        #     http_response.signal_done
        #
        # @overload signal_done()
        #
        # @overload signal_done(options = {})
        #   @option options [required, Integer] :status_code
        #   @option options [required, Hash] :headers
        #   @option options [required, String] :body
        #
        def signal_done(options = {})
          if options.keys.sort == %i[body headers status_code]
            signal_headers(options[:status_code], options[:headers])
            signal_data(options[:body])
            signal_done
          elsif options.empty?
            @body.rewind if @body.respond_to?(:rewind)
            @done = true
            emit(:done)
          else
            msg = 'options must be empty or must contain :status_code, :headers, ' \
                  'and :body'
            raise ArgumentError, msg
          end
        end

        # @param [StandardError] error
        def signal_error(error)
          @error = error
          signal_done
        end

        # @param [Integer, Range<Integer>] status_code_range
        # @yield A block to be called when headers are received.
        def on_headers(status_code_range = nil, &block)
          @listeners[:headers] << listener(status_code_range, block)
        end

        # @yield A block to be called when data is received.
        def on_data(&block)
          @listeners[:data] << block
        end

        # @param [Integer, Range<Integer>] status_code_range
        # @yield A block to be called when the response is complete.
        def on_done(status_code_range = nil, &block)
          listener = listener(status_code_range, block)
          if @done
            listener.call
          else
            @listeners[:done] << listener
          end
        end

        # @param [Integer, Range<Integer>] status_code_range
        # @yield A block to be called when the response is successful.
        def on_success(status_code_range = 200..599)
          on_done(status_code_range) do
            yield unless @error
          end
        end

        # @yieldparam [StandardError] error
        # @yield A block to be called when an error occurs.
        def on_error
          on_done(0..599) do
            yield(@error) if @error
          end
        end

        # Resets the HTTP response.
        def reset
          @status_code = 0
          @headers.clear
          @body.truncate(0)
          @error = nil
        end

        private

        def listener(range, block)
          range = range..range if range.is_a?(Integer)
          if range
            lambda do |*args|
              block.call(*args) if range.include?(@status_code)
            end
          else
            block
          end
        end

        def emit(event_name, *args)
          @listeners[event_name].each { |listener| listener.call(*args) }
        end
      end
    end
  end
end
