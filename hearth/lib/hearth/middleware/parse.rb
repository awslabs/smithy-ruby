# frozen_string_literal: true

module Hearth
  module Middleware
    # A middleware that parses a response object.
    # @api private
    class Parse
      # @param [Class] app The next middleware in the stack.
      # @param [Class] error_parser A parser object responsible for parsing the
      #  response if there is an error. It must respond to #parse and take the
      #  response as an argument.
      # @param [Class] data_parser A parser object responsible for parsing the
      #  response if there is data. It must respond to #parse and take the
      #  response as an argument.
      def initialize(app, error_parser:, data_parser:)
        @app = app
        @error_parser = error_parser
        @data_parser = data_parser
      end

      # @param input
      # @param context
      # @return [Output]
      def call(input, context)
        output = @app.call(input, context)
        parse_error(context, output) unless output.error
        parse_data(context, output) unless output.error
        output
      end

      private

      def parse_error(context, output)
        output.error = @error_parser.parse(context.response, output.metadata)
      end

      def parse_data(context, output)
        output.data = @data_parser.parse(context.response)
      end
    end
  end
end
