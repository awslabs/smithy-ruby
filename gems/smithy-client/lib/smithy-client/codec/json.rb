# frozen_string_literal: true

module Smithy
  module Client
    module Codec
      # Codec that serializes and deserializes in JSON format.
      # TODO:
      #   * Support (de)serializing union shapes once union is supported
      #   * Support handling of typed document when it is supported
      #   * Update implementation ot handle event streams
      #   * Update to handle the following traits:
      #     * timestampFormat trait (useTimeStampFormat)
      #     * jsonName trait (useJsonName)
      #     * queryCompatible trait
      #   * Setting tracks the following states (borrowed)
      #     * defaultTimestampFormat
      #     * forbidUnknownUnionMembers
      class JSON
        include Shapes

        def initialize(options = {})
          # TODO: Need to handle JSON traits
          @timestamp_format = options[:timestamp_format]
        end

        # @param [Object] data
        # @param [Shape] shape
        # @return [String<JSON>] serialized data
        def serialize(data, shape)
          Client::JSON.dump(format_data(data, shape))
        end

        # @param [String<JSON>] data
        # @param [Shape] shape
        # @param [Struct] type
        # @return [Object, Hash]
        def deserialize(data, shape, type = nil)
          data = '{}' if data.empty?

          parse_data(Client::JSON.parse(data), shape, type)
        end

        private

        def format_blob(value)
          Base64.strict_encode64(value.is_a?(String) ? value : value.read)
        end

        def format_data(value, shape)
          case shape
          when StructureShape then format_structure(value, shape)
          when ListShape      then format_list(value, shape)
          when MapShape       then format_map(value, shape)
          when TimestampShape then format_timestamp(value)
          when BlobShape      then format_blob(value)
          when FloatShape     then format_float(value)
          else value
          end
        end

        def format_float(value)
          if value == ::Float::INFINITY
            'Infinity'
          elsif value == -::Float::INFINITY then '-Infinity'
          elsif value&.nan? then 'NaN'
          else
            value
          end
        end

        def format_list(values, shape)
          return nil if values.nil?

          values.collect { |value| format_data(shape.member.shape, value) }
        end

        def format_map(values, shape)
          return nil if values.nil?

          values.each.with_object({}) do |(key, value), data|
            data[key] = format_data(value, shape.value.shape)
          end
        end

        def format_structure(values, shape)
          return nil if values.nil?

          values.each_pair.with_object({}) do |(key, value), data|
            if shape.member?(key) && !value.nil?
              member = shape.member(key)
              data[member.name] = format_data(value, member.shape)
            end
          end
        end

        def format_timestamp(value)
          case @timestamp_format
          when 'date-time' then Client::TimeHelper.to_date_time(value)
          when 'http-date' then Client::TimeHelper.to_http_date(value)
          when 'epoch-seconds' then Client::TimeHelper.to_epoch_seconds(value)
          end
        end

        def parse_data(value, shape, type = nil)
          return nil if value.nil?

          case shape
          when StructureShape then parse_structure(value, shape, type)
          when ListShape then parse_list(value, shape, type)
          when MapShape then parse_map(value, shape, type)
          when TimestampShape then time(value)
          when BlobShape then Base64.decode64(value)
          when BooleanShape then value.to_s == 'true'
          when FloatShape then parse_float(value)
          else value
          end
        end

        def parse_float(value)
          case value
          when 'Infinity' then ::Float::INFINITY
          when '-Infinity' then -::Float::INFINITY
          when 'NaN' then ::Float::NAN
          when nil then nil
          else value.to_f
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
            next if value.nil?

            target[key] = parse_data(shape.value.shape, value)
          end
          target
        end

        def parse_structure(shape, values, type = nil)
          target = shape.type.new if target.nil?
          values.each do |key, value|
            if (member = shape.member(key))
              target[member.name] = parse_data(member.shape, value, type)
            end
          end
          target
        end

        def parse_time(value)
          value.is_a?(Numeric) ? Time.at(value) : deserialize_time(value)
        end

        def deserialize_time(value)
          case value
          when nil then nil
          when /^[\d.]+$/ then Time.at(value.to_f).utc
          else
            begin
              fractional_time = Time.parse(value).to_f
              Time.at(fractional_time).utc
            rescue ArgumentError
              raise "unhandled timestamp format `#{value}'"
            end
          end
        end
      end
    end
  end
end
