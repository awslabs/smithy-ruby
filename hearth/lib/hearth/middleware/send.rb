# frozen_string_literal: true

module Hearth
  module Middleware
    # A middleware used to send the request.
    # @api private
    class Send
      # @param [Class] _app The next middleware in the stack.
      # @param [Boolean] stub_responses If true, a request is not sent and a
      #   stubbed response is returned.
      # @param [Class] stub_data_class A stub object that is responsible for
      #   creating a stubbed data response. It must respond to #stub and take
      #   the response and stub data as arguments.
      # @param [Array<Class>] stub_error_classes An array of error classes
      #   that are responsible for creating a stubbed error response. They
      #   must respond to #stub and take the response and stub data as
      #   arguments.
      # @param [Stubs] stubs A {Hearth::Stubs} object containing
      #   stubbed data for any given operation.
      def initialize(_app, client:, stub_responses:,
                     stub_data_class:, stub_error_classes:, stubs:)
        @client = client
        @stub_responses = stub_responses
        @stub_data_class = stub_data_class
        @stub_error_classes = stub_error_classes
        @stubs = stubs
      end

      # @param input
      # @param context
      # @return [Output]
      def call(input, context)
        interceptor_error = context.interceptors.apply(
          hook: Interceptor::Hooks::MODIFY_BEFORE_TRANSMIT,
          input: input,
          context: context,
          output: nil,
          aggregate_errors: false
        )
        return Hearth::Output.new(error: interceptor_error) if interceptor_error

        interceptor_error = context.interceptors.apply(
          hook: Interceptor::Hooks::READ_BEFORE_TRANSMIT,
          input: input,
          context: context,
          output: nil,
          aggregate_errors: true
        )
        return Hearth::Output.new(error: interceptor_error) if interceptor_error

        output = Output.new
        if @stub_responses
          stub_response(input, context, output)
        else
          send_request(context, output)
        end

        interceptor_error = context.interceptors.apply(
          hook: Interceptor::Hooks::READ_AFTER_TRANSMIT,
          input: input,
          context: context,
          output: output,
          aggregate_errors: true
        )
        output.error = interceptor_error if interceptor_error

        output
      end

      private

      def stub_response(input, context, output)
        stub = @stubs.next(context.operation_name)
        apply_stub(stub, input, context, output)
        return unless context.response.body.respond_to?(:rewind)

        context.response.body.rewind
      end

      def send_request(context, output)
        @client.transmit(
          request: context.request,
          response: context.response,
          logger: context.logger
        )
      rescue Hearth::NetworkingError => e
        output.error = e
      end

      def apply_stub(stub, input, context, output)
        case stub
        when Proc
          stub = stub.call(input)
          apply_stub(stub, input, context, output) if stub
        when Exception, ApiError
          output.error = stub
        when Hash
          apply_stub_hash(stub, context)
        when NilClass
          apply_stub_nil(context)
        when Hearth::Structure
          apply_stub_hearth_structure(stub, context)
        when Hearth::Response
          context.response = stub
        else
          raise ArgumentError, 'Unsupported stub type'
        end
      end

      def apply_stub_hash(stub, context)
        if stub.key?(:error) && !stub.key?(:data)
          apply_stub_hash_error(stub, context)
        elsif stub.key?(:data) && !stub.key?(:error)
          apply_stub_hash_data(stub, context)
        else
          raise ArgumentError, 'Unsupported stub hash, must be :data or :error'
        end
      end

      def apply_stub_hash_data(stub, context)
        output = @stub_data_class.build(stub[:data], context: 'stub')
        @stub_data_class.validate!(output, context: 'stub')
        @stub_data_class.stub(context.response, stub: output)
      end

      def apply_stub_hash_error(stub, context)
        stub_error_class = stub_error_class(stub[:error][:class])
        output = stub_error_class.build(
          stub[:error][:data] || {},
          context: 'stub'
        )
        stub_error_class.validate!(output, context: 'stub')
        stub_error_class.stub(context.response, stub: output)
      end

      def stub_error_class(error_class)
        raise ArgumentError, 'Missing stub error class' unless error_class

        unless error_class.is_a?(Class)
          raise ArgumentError, 'Stub error class must be a class'
        end

        error_base_name = error_class.name.split('::').last
        stub_class = @stub_error_classes.find do |stub_error_class|
          stub_base_name = stub_error_class.name.split('::').last
          error_base_name == stub_base_name
        end
        raise ArgumentError, 'Unsupported stub error class' unless stub_class

        stub_class
      end

      def apply_stub_nil(context)
        output = @stub_data_class.build(
          @stub_data_class.default,
          context: 'stub'
        )
        @stub_data_class.validate!(output, context: 'stub')
        @stub_data_class.stub(context.response, stub: output)
      end

      def apply_stub_hearth_structure(stub, context)
        @stub_data_class.validate!(stub, context: 'stub')
        @stub_data_class.stub(context.response, stub: stub)
      end
    end
  end
end
