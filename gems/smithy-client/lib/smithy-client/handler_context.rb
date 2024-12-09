# frozen_string_literal: true

module Smithy
  module Client
    # Context that is passed to handlers during execution.
    class HandlerContext
      # @option options [Symbol] :operation_name (nil)
      # @option options [Operation] :operation (nil)
      # @option options [Base] :client (nil)
      # @option options [Hash] :params ({})
      # @option options [Configuration] :config (nil)
      # @option options [Request] :request (nil)
      # @option options [Response] :response (nil)
      # @options options [Hash] :metadata ({})
      def initialize(options = {})
        @operation_name = options[:operation_name]
        @operation = options[:operation]
        @client = options[:client]
        @params = options[:params] || {}
        @config = options[:config]
        @request = options[:request]
        @response = options[:response]
        @metadata = {}
      end

      # @return [Symbol] Name of the API operation called.
      attr_accessor :operation_name

      # @return [Operation]
      attr_accessor :operation

      # @return [Base]
      attr_accessor :client

      # @return [Hash] The hash of request parameters.
      attr_accessor :params

      # @return [Configuration] The client configuration.
      attr_accessor :config

      # @return [Request]
      attr_accessor :request

      # @return [Response]
      attr_accessor :response

      # @return [Hash]
      attr_reader :metadata

      # @param [Symbol] key
      # @return [Object]
      def [](key)
        @metadata[key]
      end

      # @param [Symbol] key
      # @param [Object] value
      def []=(key, value)
        @metadata[key] = value
      end
    end
  end
end
