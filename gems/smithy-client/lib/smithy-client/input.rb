# frozen_string_literal: true

module Smithy
  module Client
    # Represents the input to a service operation call.
    class Input
      include HandlerBuilder

      # @option options [HandlerList] :handlers (nil)
      # @option options [HandlerContext] :context (nil)
      def initialize(options = {})
        @handlers = options[:handlers] || HandlerList.new
        @context = options[:context] || HandlerContext.new
      end

      # @return [HandlerList]
      attr_reader :handlers

      # @return [HandlerContext]
      attr_reader :context

      # Sends the request, returning an {Output} object.
      #
      #     output = input.send_request
      #
      # # Streaming Responses
      #
      # By default, responses are buffered into memory. This can be
      # bad if you are downloading large responses, e.g. large files.
      # You can avoid this by streaming the response to a block or some other
      # target.
      #
      # ## Streaming to a File
      #
      # You can stream the raw response bodies to a File, or any IO-like
      # object, by passing the `:target` option.
      #
      #     # create a new file at the given path
      #     input.send_request(target: '/path/to/target/file')
      #
      #     # or provide an IO object to write to
      #     File.open('photo.jpg', 'wb') do |file|
      #       input.send_request(target: file)
      #     end
      #
      # **Please Note**: The target IO object may receive `#truncate(0)`
      # if the request generates a networking error and bytes have already
      # been written to the target.
      #
      # ## Block Streaming
      #
      # Pass a block to `#send_request` and the response will be yielded in
      # chunks to the given block.
      #
      #     # stream the response data
      #     input.send_request do |chunk|
      #       file.write(chunk)
      #     end
      #
      # **Please Note**: When streaming to a block, it is not possible to
      # retry failed requests.
      #
      # @option options [String, IO] :target When specified, the response
      #   body is written to the target. This is helpful when you are sending
      #   a request that may return a large payload that you don't want to
      #   load into memory.
      #
      # @return [Output, nil]
      #
      def send_request(options = {}, &block)
        @context[:response_target] = options[:target] || block
        @handlers.to_stack&.call(@context)
      end
    end
  end
end
