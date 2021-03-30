# frozen_string_literal: true

module Seahorse
  module Middleware
    class Retry

      def initialize(app, max_attempts:, max_delay:)
        @app = app
        @max_attempts = max_attempts
        @max_delay = max_delay
      end

      # @param request
      # @param response
      # @param context
      # @return [Output]
      def call(request:, response:, context:)
        attempt = 1
        begin
          @app.call(
            request: request,
            response: response,
            context: context
          )
        rescue Seahorse::HTTP::NetworkingError => error
          if attempt < @max_attempts
            sleep(backoff_with_jitter(attempt))
            attempt += 1
            retry
          else
            raise error
          end
        end
      end

      private

      # https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/
      def backoff_with_jitter(attempt)
        # scales like 1,2,4,8
        Kernel.rand * ([@max_delay, 2 ** (attempt - 1)].min)
      end

    end
  end
end
