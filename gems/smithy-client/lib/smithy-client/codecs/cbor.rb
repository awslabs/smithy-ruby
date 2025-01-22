# frozen_string_literal: true

require 'base64'

module Smithy
  module Client
    module Codecs
      # Codec that serializes and deserializes in CBOR format.
      # TODO:
      #   * Support (de)serializing union shapes once union is supported
      #   * Support handling of typed documents when it is supported
      #   * Update implementation to handle event streams
      #   * Handle query_compatible trait
      class CBOR
        include Shapes

        def initialize(options = {}); end

        # @param [Object] data
        # @param [Shape] shape
        # @return [String] the encoded bytes in CBOR format
        def serialize(data, shape)
          return nil if shape == Unit

          Client::CBOR.encode(format_data(data, shape))
        end

        # @param [String] bytes
        # @param [Shape] shape
        # @param [Struct] type
        # @return [Object, Hash]
        def deserialize(bytes, shape, type = nil)
          return {} if bytes.empty?

          parse_data(Client::CBOR.decode(bytes), shape, type)
        end

        private

        def format_blob(value)
          (value.is_a?(::String) ? value : value.read).force_encoding(Encoding::BINARY)
        end

        def format_data(value, shape)
          case shape
          when StructureShape then format_structure(value, shape)
          when ListShape      then format_list(value, shape)
          when MapShape       then format_map(value, shape)
          when BlobShape      then format_blob(value)
          else value
          end
        end

        def format_list(values, shape)
          values.collect { |value| format_data(value, shape.member.shape) }
        end

        def format_map(values, shape)
          values.each.with_object({}) do |(key, value), data|
            data[key] = format_data(value, shape.value.shape)
          end
        end

        def format_structure(values, shape)
          values.each_pair.with_object({}) do |(key, value), data|
            if shape.member?(key) && !value.nil?
              member = shape.member(key)
              data[key] = format_data(value, member.shape)
            end
          end
        end

        def parse_data(value, shape, type = nil)
          return nil if value.nil?

          case shape
          when StructureShape then parse_structure(value, shape, type)
          when ListShape then parse_list(value, shape, type)
          when MapShape then parse_map(value, shape, type)
          else value
          end
        end

        def parse_list(values, shape, target = nil)
          target = [] if target.nil?
          values.each do |value|
            target << parse_data(value, shape.member.shape)
          end
          target
        end

        def parse_map(values, shape, target = nil)
          target = {} if target.nil?
          values.each do |key, value|
            target[key] = parse_data(value, shape.value.shape) unless value.nil?
          end
          target
        end

        def parse_structure(values, shape, target = nil)
          target = shape.type.new if target.nil?
          values.each do |key, value|
            if (member = shape.member(key.to_sym))
              target[key] = parse_data(value, member.shape)
            end
          end
          target
        end
      end
    end
  end
end
