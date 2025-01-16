# frozen_string_literal: true

require 'base64'

module Smithy
  module Client
    # Codec that serializes and deserializes in CBOR format.
    class CBORCodec
      include Shapes

      # @option options [Symbol] :xml_flattened (nil)
      def initialize(options = {})
        # TODO: Need to add implementation to handle this trait
        @xml_flattened = options[:xml_flattened] || false
      end

      # @param [Object] data
      # @param [Shape] shape
      # @return [String] the encoded bytes in CBOR format
      def serialize(data, shape)
        return nil if shape == Unit

        CBOR.encode(format_data(shape, data))
      end

      # @param [String] bytes
      # @param [Shape] shape
      # @param [Struct] type
      # @return [Object, Hash]
      def deserialize(bytes, shape, type = nil)
        return {} if bytes.empty?

        parse_data(shape, CBOR.decode(bytes), type)
      end

      private

      def format_blob(value)
        (value.is_a?(::String) ? value : value.read).force_encoding(Encoding::BINARY)
      end

      def format_data(shape, value)
        case shape
        when StructureShape then format_structure(shape, value)
        when ListShape      then format_list(shape, value)
        when MapShape       then format_map(shape, value)
        when BlobShape      then format_blob(value)
        else value
        end
      end

      def format_list(shape, values)
        values.collect { |value| format_data(shape.member.shape, value) }
      end

      def format_map(shape, values)
        values.each.with_object({}) do |(key, value), data|
          data[key] = format_data(shape.value.shape, value)
        end
      end

      def format_structure(shape, values)
        values.each_pair.with_object({}) do |(key, value), data|
          if shape.member?(key) && !value.nil?
            member = shape.member(key)
            data[member.name] = format_data(member.shape, value)
          end
        end
      end

      # TODO: Support union shapes and handle event streams
      def parse_data(shape, value, target = nil)
        if value.nil?
          nil
        else
          case shape
          when StructureShape then parse_structure(shape, value, target)
          when ListShape then parse_list(shape, value, target)
          when MapShape then parse_map(shape, value, target)
          else value
          end
        end
      end

      def parse_list(shape, values, target = nil)
        target = [] if target.nil?
        values.each do |value|
          target << parse_data(shape.member.shape, value)
        end
        target
      end

      def parse_map(shape, values, target = nil)
        target = {} if target.nil?
        values.each do |key, value|
          target[key] = parse_data(shape.value.shape, value) unless value.nil?
        end
        target
      end

      def parse_structure(shape, values, target = nil)
        target = shape.type.new if target.nil?
        values.each do |key, value|
          if (member = shape.member(key))
            target[member.name] = parse_data(member.shape, value)
          end
        end
        target
      end
    end
  end
end
