# frozen_string_literal: true

module Smithy
  module Vise
    # Finds all shapes for an operation.
    class OperationIndex
      # @param [Hash] model Model
      def initialize(model)
        @operation_parser = OperationParser.new(model)
        @memo = {}
      end

      # @param [Hash] operation Operation shape
      # @return [Hash<String, Hash>] The shapes for the operation.
      def shapes_for(operation)
        @memo[operation] ||= @operation_parser.shapes_for(operation)
      end
    end
  end
end
