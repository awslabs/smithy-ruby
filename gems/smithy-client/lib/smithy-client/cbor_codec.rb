# frozen_string_literal: true

require 'base64'

module Smithy
  module Client
    # @api private
    class CborCodec
      include Shapes

      def serialize(data, shape)
        return nil if shape == Unit

        Cbor.encode(format_data(shape, data))
      end

      # target here means type to parse into
      def deserialize(bytes, shape, target = nil)
        return {} if bytes.empty?

        decoded_data = Cbor.decode(bytes)
        parse_data(shape, decoded_data, target)
      end

      private

      def format_blob(value)
        (value.is_a?(String) ? value : value.read).force_encoding(Encoding::BINARY)
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
        values.collect { |value| format_data(shape.member, value) }
      end

      def format_map(shape, values)
        value_ref = shape.value
        values.each.with_object({}) do |(key, value), data|
          data[key] = format_data(value_ref, value)
        end
      end

      def format_structure(shape, values)
        values.each_pair.with_object({}) do |(key, value), data|
          if shape.member?(key) && !value.nil?
            member_shape = shape.member(key)
            data[member_shape.name] =
              format_data(member_shape, value)
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
          target << parse_data(shape.member, value)
        end
        target
      end

      def parse_map(shape, values, target = nil)
        target = {} if target.nil?
        values.each do |key, value|
          target[key] = parse_data(shape.value, value) unless value.nil?
        end
        target
      end

      def parse_structure(shape, values, target = nil)
        target = shape.type.new if target.nil?
        values.each do |key, value|
          if (member_shape = shape.member(key))
            target[member_shape.name] = parse_data(member_shape, value)
          end
        end
        target
      end
    end
  end
end
