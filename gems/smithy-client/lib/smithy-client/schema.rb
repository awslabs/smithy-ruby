# frozen_string_literal: true

module Smithy
  module Client
    # @api private
    class Schema
      include Enumerable

      def initialize
        @service = nil
        @operations = {}
        yield self if block_given?
      end

      # @return [ServiceShape, nil]
      attr_accessor :service

      # @return [Hash<Symbol, OperationShape>]
      attr_accessor :operations

      # @return [OperationShape]
      def add_operation(name, operation)
        @operations[name] = operation
      end

      # @return [Hash<Symbol, OperationShape>]
      def each(&)
        @operations.each(&)
      end

      # @return [String]
      def inspect
        "#<#{self.class.name}>"
      end

      # @param [Symbol] name
      # @return [OperationShape] operation
      def operation(name)
        raise ArgumentError, "unknown operation #{name.inspect}" unless @operations.key?(name)

        @operations[name]
      end

      # @return [Array<Symbol>]
      def operation_names
        @operations.keys
      end
    end
  end
end
