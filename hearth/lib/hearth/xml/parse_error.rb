# frozen_string_literal: true

module Hearth
  module XML
    # An error class encountered when parsing XML.
    class ParseError < StandardError
      MSG = 'Encountered an error while parsing the response: %<message>s'

      def initialize(original_error)
        @original_error = original_error
        super(format(MSG, message: original_error.message))
      end

      # @return [StandardError]
      attr_reader :original_error
    end
  end
end
