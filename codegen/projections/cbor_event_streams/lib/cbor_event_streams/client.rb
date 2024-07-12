# frozen_string_literal: true

# WARNING ABOUT GENERATED CODE
#
# This file was code generated using smithy-ruby.
# https://github.com/smithy-lang/smithy-ruby
#
# WARNING ABOUT GENERATED CODE

require 'stringio'

require_relative 'plugins/global_config'

module CborEventStreams
  class Client < Hearth::Client

    # @api private
    @plugins = Hearth::PluginList.new([
      Plugins::GlobalConfig.new
    ])

    # @param [Hash] options
    #   Options used to construct an instance of {Config}
    def initialize(options = {})
      super(options, Config)
    end

    # @return [Config] config
    attr_reader :config

    # @param [Hash | Types::NonStreamingOperationInput] params
    #   Request parameters for this operation.
    #   See {Types::NonStreamingOperationInput#initialize} for available parameters.
    # @param [Hash] options
    #   Request option override of configuration. See {Config#initialize} for available options.
    #   Some configurations cannot be overridden.
    # @return [Hearth::Output]
    # @example Request syntax with placeholder values
    #   resp = client.non_streaming_operation(
    #     input_value: 'inputValue'
    #   )
    # @example Response structure
    #   resp.data #=> Types::NonStreamingOperationOutput
    #   resp.data.output_value #=> String
    def non_streaming_operation(params = {}, options = {})
      response_body = ::StringIO.new
      config = operation_config(options)
      input = Params::NonStreamingOperationInput.build(params, context: 'params')
      stack = CborEventStreams::Middleware::NonStreamingOperation.build(config)
      context = Hearth::Context.new(
        request: Hearth::HTTP::Request.new(uri: URI('')),
        response: Hearth::HTTP::Response.new(body: response_body),
        config: config,
        operation_name: :non_streaming_operation,
      )
      context.config.logger.info("[#{context.invocation_id}] [#{self.class}#non_streaming_operation] params: #{params}, options: #{options}")
      output = stack.run(input, context)
      if output.error
        context.config.logger.error("[#{context.invocation_id}] [#{self.class}#non_streaming_operation] #{output.error} (#{output.error.class})")
        raise output.error
      end
      context.config.logger.info("[#{context.invocation_id}] [#{self.class}#non_streaming_operation] #{output.data}")
      output
    end

    # @param [Hash | Types::StartEventStreamInput] params
    #   Request parameters for this operation.
    #   See {Types::StartEventStreamInput#initialize} for available parameters.
    # @param [Hash] options
    #   Request option override of configuration. See {Config#initialize} for available options.
    #   Some configurations cannot be overridden.
    # @return [Hearth::Output]
    # @example Request syntax with placeholder values
    #   resp = client.start_event_stream(
    #     event: {
    #       # One of:
    #       event_a: {
    #         message: 'message'
    #       },
    #       event_b: {
    #         nested: {
    #           member_values: [
    #             'member'
    #           ]
    #         }
    #       }
    #     }
    #   )
    # @example Response structure
    #   resp.data #=> Types::StartEventStreamOutput
    #   resp.data.event #=> Types::Events, one of [EventA, EventB]
    #   resp.data.event.event_a #=> Types::EventA
    #   resp.data.event.event_a.message #=> String
    #   resp.data.event.event_b #=> Types::EventB
    #   resp.data.event.event_b.nested #=> Types::NestedEvent
    #   resp.data.event.event_b.nested.member_values #=> Array<String>
    #   resp.data.event.event_b.nested.member_values[0] #=> String
    def start_event_stream(params = {}, options = {})
      middleware_opts = {}
      middleware_opts[:event_stream_handler] = options.delete(:event_stream_handler)
      raise ArgumentError, 'Missing `event_stream_handler`' unless middleware_opts[:event_stream_handler]
      response_body = ::StringIO.new
      config = operation_config(options)
      input = Params::StartEventStreamInput.build(params, context: 'params')
      stack = CborEventStreams::Middleware::StartEventStream.build(config, middleware_opts)
      context = Hearth::Context.new(
        request: Hearth::HTTP::Request.new(uri: URI('')),
        response: Hearth::HTTP::Response.new(body: response_body),
        config: config,
        operation_name: :start_event_stream,
      )
      context.config.logger.info("[#{context.invocation_id}] [#{self.class}#start_event_stream] params: #{params}, options: #{options}")
      output = stack.run(input, context)
      if output.error
        context.config.logger.error("[#{context.invocation_id}] [#{self.class}#start_event_stream] #{output.error} (#{output.error.class})")
        raise output.error
      end
      context.config.logger.info("[#{context.invocation_id}] [#{self.class}#start_event_stream] #{output.data}")
      output
    end
  end
end
