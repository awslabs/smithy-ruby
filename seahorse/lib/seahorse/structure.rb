# frozen_string_literal: true

module Seahorse
  # A module mixed into Structs that provides utility methods.
  module Structure
    # Deeply converts the Struct into a hash. Structure members that
    # are `nil` are omitted from the resultant hash.
    #
    # @return [Hash]
    def to_h(obj = self)
      case obj
      when Struct
        _to_h_struct(obj)
      when Hash
        _to_h_hash(obj)
      when Array
        obj.collect { |value| to_hash(value) }
      else
        !obj.nil? && obj.respond_to?(:to_h) ? obj.to_h : obj
      end
    end
    alias to_hash to_h

    private

    def _to_h_struct(obj)
      obj.each_pair.with_object({}) do |(member, value), hash|
        hash[member] = to_hash(value) unless value.nil?
      end
    end

    def _to_h_hash(obj)
      obj.each.with_object({}) do |(key, value), hash|
        hash[key] = to_hash(value)
      end
    end
  end
end
