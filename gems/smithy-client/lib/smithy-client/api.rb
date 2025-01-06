# frozen_string_literal: true

module Smithy
  module Client
    # @api private
    class API
      include Enumerable

      def initialize
        @metadata = {}
        @operations = {}
        yield self if block_given?
      end

      # @return [String, nil]
      attr_accessor :version

      # @return [Hash]
      attr_accessor :metadata

      def each(&)
        @operations.each(&)
      end

      # @return [Array<Symbol>]
      def add_operation(name, operation)
        @operations[name] = operation
      end

      # @param [String] name
      # @return [Operation]
      def operation(name)
        raise ArgumentError, "unknown operation #{name.inspect}" unless @operations.key?(name)

        @operations[name.to_sym]
      end

      # @return [Array<Symbol>]
      def operation_names
        @operations.keys
      end

      # @api private
      def inspect
        "#<#{self.class.name}>"
      end
    end
  end
end
