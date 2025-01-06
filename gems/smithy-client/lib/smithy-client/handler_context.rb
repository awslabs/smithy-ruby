# frozen_string_literal: true

module Smithy
  module Client
    # Context that is passed to handlers during execution.
    class HandlerContext
      # @option options [Symbol] :operation_name (nil)
      # @option options [OperationShape] :operation (nil)
      # @option options [Base] :client (nil)
      # @option options [Hash] :params ({})
      # @option options [Configuration] :config (nil)
      # @option options [Request] :request (HTTP::Request.new)
      # @option options [Response] :response (HTTP::Response.new)
      # @options options [Hash] :metadata ({})
      def initialize(options = {})
        @operation_name = options[:operation_name]
        @operation = options[:operation]
        @client = options[:client]
        @params = options[:params] || {}
        @config = options[:config]
        @request = options[:request] || HTTP::Request.new
        @response = options[:response] || HTTP::Response.new
        @metadata = {}
      end

      # @return [Symbol] Name of the API operation called.
      attr_accessor :operation_name

      # @return [OperationShape] Shape of the Operation called.
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
