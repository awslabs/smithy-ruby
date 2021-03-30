module Seahorse
  module HTTP
    # Uses HTTP specific logic + Protocol defined Errors and
    # Error Code function to determine if a response should
    # be parsed as an Error. Contains generic Error parsing
    # logic as well.
    # @api private
    class ErrorParser

      # @api private
      HTTP_3XX = 300..399

      # @api private
      HTTP_4XX = 400..499

      # @api private
      HTTP_5XX = 500..599

      # @param [Module] :error_module - the code generated Errors module.
      #   Must contain service specific implementations of
      #   ApiRedirectError, ApiClientError and ApiServerError
      #
      # @param [Integer] :success_status_code - The status code of a
      #   successful response as defined by the model for
      #   this operation. If this is a non 2XX value,
      #   the request will be considered successful if
      #   it has the success_status_code and does not
      #   have an error code.
      #
      # @param [Array<Class < APIError>] :errors  -
      #   Array of Error classes modeled for the operation.
      #
      # @param [callable] :error_code_fn -
      #   Protocol specific function that will return
      #   the error code from a response, or nil if
      #   there is none.
      def initialize(error_module:, success_status_code:, errors:, error_code_fn:)
        @error_module = error_module
        @success_status_code = success_status_code
        @errors = errors
        @error_code_fn = error_code_fn
      end

      # parse and set the error on the response if
      # the response is not success.
      #
      # @param [Response]
      def parse(response:)
        extract_error(response) if error?(response)
      end

      private

      # Implements the following order of precedence
      # 1. Response has error_code -> error
      # 2. Response code == http trait status code? -> success
      # 3. Response code matches any error status codes? -> error  [EXCLUDED, covered by error_code]
      # 4. Response code is 2xx? -> success
      # 6. Response code 5xx -> unknown server error [MODIFIED, 3xx, 4xx, 5xx mapped, everything else is Generic ApiError]
      # 7. Everything else -> unknown client error
      def error?(http_resp)
        return true if @error_code_fn.call(http_resp)
        return false if http_resp.status_code == @success_status_code

        return !(200..299).cover?(http_resp.status_code)
      end

      def extract_error(http_resp)
        error_code = @error_code_fn.call(http_resp)
        error_class = @errors.find{ |e| e.name.include? error_code } if error_code

        error_opts = {
          http_resp: http_resp,
          error_code: error_code,
          message: nil, # must be set later
        }

        if error_class
          error_class.new(**error_opts)
        else
          case http_resp.status_code
          when HTTP_3XX then @error_module::ApiRedirectError.new(location: http_resp.headers['location'], **error_opts)
          when HTTP_4XX then @error_module::ApiClientError.new(**error_opts)
          when HTTP_5XX then @error_module::ApiServerError.new(**error_opts)
          else @error_module::ApiError.new(http_resp: http_resp, **error_opts)
          end
        end
      end
    end
  end
end
