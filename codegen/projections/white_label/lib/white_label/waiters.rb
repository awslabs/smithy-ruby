# frozen_string_literal: true

# WARNING ABOUT GENERATED CODE
#
# This file was code generated using smithy-ruby.
# https://github.com/awslabs/smithy-ruby
#
# WARNING ABOUT GENERATED CODE

module WhiteLabel
  module Waiters

    # Test that this waiter exists
    class ResourceExists
      # @param [Client] client
      # @param [Hash] options
      # @option options [required, Integer] :max_wait_time The maximum time in
      # seconds to wait before the waiter gives up.
      # @option options [Integer] :min_delay (10) The minimum time in seconds to
      # delay polling attempts.
      # @option options [Integer] :max_delay (100) The maximum time in seconds
      # to delay polling attempts.
      def initialize(client, options = {})
        @client = client
        @waiter = Seahorse::Waiters::Waiter.new({
          max_wait_time: options[:max_wait_time],
          min_delay: 10 || options[:min_delay],
          max_delay: 100 || options[:max_delay],
          poller: Seahorse::Waiters::Poller.new(
            operation_name: :waiters_test,
            acceptors: [
              {
                state: 'success',
                matcher: {
                  success: true
                }
              },
              {
                state: 'retry',
                matcher: {
                  errorType: 'NotFound'
                }
              },
              {
                state: 'failure',
                matcher: {
                  output: 'Status'
                }
              },
              {
                state: 'failure',
                matcher: {
                  inputOutput: 'input.Status == output.Status'
                }
              }
            ]
          )
        }.merge(options))
        @tags = ["waiter", "test"]
      end

      attr_reader :tags

      # @param [Hash] params (see Client#waiters_test)
      # @param [Hash] options (see Client#waiters_test)
      # @return (see Client#waiters_test)
      def wait(params = {}, options = {})
        @waiter.wait(@client, params, options)
      end
    end

  end
end
