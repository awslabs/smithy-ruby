# frozen_string_literal: true

require 'json'

module Smithy
  module Client
    # Smithy::Client::JSON is a purpose-built set of utilities for
    # working with JSON. It does not support many/most features
    # of generic JSON parsing and serialization
    # @api private
    module JSON
      # An error class encountered when parsing JSON.
      class ParseError < StandardError
        MSG = 'Encountered an error while parsing the response: %<message>s'

        def initialize(original_error)
          @original_error = original_error
          super(format(MSG, message: original_error.message))
        end

        # @return [StandardError]
        attr_reader :original_error
      end

      class << self
        # @param [String] json
        # @return [Hash]
        def parse(json)
          return nil if json.empty?

          ::JSON.parse(json)
        rescue ::JSON::ParserError => e
          raise ParseError, e
        end

        # @param [Object] value
        # @return [String] json
        def dump(value)
          ::JSON.dump(value)
        end
      end
    end
  end
end
