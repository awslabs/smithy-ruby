# frozen_string_literal: true

require 'delegate'

module Smithy
  module Client
    # Represents the output of a service operation call.
    class Output < Delegator
      # @option options [HandlerContext] :context (nil)
      # @option options [Structure] :data (nil)
      # @option options [StandardError] :error (nil)
      def initialize(options = {})
        @context = options[:context] || HandlerContext.new
        @data = options[:data]
        @error = options[:error]
        @request = @context.request
        @response = @context.response
        @response.on_error { |error| @error = error }
        super(@data)
      end

      # @return [HandlerContext]
      attr_reader :context

      # @return [Structure, nil] The response data. This may be `nil` if the
      #  response contains an {#error}.
      attr_accessor :data

      # @return [StandardError, nil] The error that occurred during the
      #  operation.  This will be `nil` if the operation was successful.
      attr_accessor :error

      # Necessary to define as a subclass of Delegator
      # @api private
      def __getobj__
        @data
      end

      # Necessary to define as a subclass of Delegator
      # @api private
      def __setobj__(obj)
        @data = obj
      end
    end
  end
end
