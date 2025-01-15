# frozen_string_literal: true

module Smithy
  module Client
    # A module mixed into Structs that provides utility methods.
    module Structure
      # Deeply converts the Struct into a hash. Structure members that
      # are `nil` are omitted from the resultant hash.
      # @return [Hash, Structure]
      def to_h(obj = self)
        case obj
        when Structure
          _to_h_structure(obj)
        when Hash
          _to_h_hash(obj)
        when Array
          _to_h_array(obj)
        else
          obj
        end
      end
      alias to_hash to_h

      private

      def _to_h_structure(obj)
        obj.members.each_with_object({}) do |member, hash|
          value = obj.send(member)
          hash[member] = to_hash(value) unless value.nil?
        end
      end

      def _to_h_hash(obj)
        obj.transform_values do |value|
          to_hash(value)
        end
      end

      def _to_h_array(obj)
        obj.collect { |value| to_hash(value) }
      end
    end

    # An empty Struct that includes the {Client::Structure} module.
    EmptyStructure = Struct.new do
      include Smithy::Client::Structure
    end
  end
end
