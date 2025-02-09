# frozen_string_literal: true

module Smithy
  module Client
    # @api private
    class ParamValidator
      include Smithy::Client::Shapes

      EXPECTED_GOT = 'expected %s to be %s, got class %s instead.'

      def self.validate!(rules, params)
        new(rules).validate!(params)
      end

      def initialize(rules)
        @rules = rules
      end

      # @param [Hash] params
      # @return [void]
      # @raise [ArgumentError] if the params are invalid
      def validate!(params)
        errors = []
        structure(@rules, params, errors, 'params')
        raise ArgumentError, error_messages(errors) unless errors.empty?
      end

      private

      def structure(shape, values, errors, context)
        return unless structure?(shape, values, errors, context)

        validate_required_members(shape, values, errors, context)
        values.each_pair do |name, value|
          next if value.nil?

          if shape.member?(name)
            member_shape = shape.member(name)
            shape(member_shape.shape, value, errors, context + "[#{name.inspect}]")
          else
            errors << "unexpected value at #{context}[#{name.inspect}]"
          end
        end
      end

      def structure?(shape, values, errors, context)
        if !values.is_a?(Hash) && values != shape.type
          errors << expected_got(context, 'a Hash', values)
          return false
        end

        true
      end

      def union(union_shape, values, errors, context)
        if !values.is_a?(Hash) && values != union_shape.type
          errors << expected_got(context, 'a Hash', values)
          return
        end

        set_values = values.to_h.length
        if set_values > 1
          errors << "multiple values provided to union at #{context} - must contain exactly one of the supported types: #{union_shape.members.keys.join(', ')}"
        end

        #TODO: nested union members
      end

      def list(shape, values, errors, context)
        # ensure the value is an array
        unless values.is_a?(Array)
          errors << expected_got(context, 'an Array', values)
          return
        end

        # validate members
        values.each.with_index do |value, index|
          next unless value

          shape(shape.member.shape, value, errors, context + "[#{index}]")
        end
      end

      def map(shape, values, errors, context)
        unless values.is_a?(Hash)
          errors << expected_got(context, 'a Hash', values)
          return
        end

        values.each do |key, value|
          shape(shape.key.shape, key, errors, "#{context} #{key.inspect} key")
          next unless value

          shape(shape.value.shape, value, errors, context + "[#{key.inspect}]")
        end
      end

      def document(shape, value, errors, context)
        document_types = [Hash, Array, Numeric, String, TrueClass, FalseClass, NilClass]
        unless document_types.any? { |t| value.is_a?(t) }
          errors << expected_got(context, "one of #{document_types.join(', ')}", value)
        end

        # recursively validate types for aggregated types
        case value
        when Hash
          value.each do |k, v|
            document(shape, v, errors, context + "[#{k}]")
          end
        when Array
          value.each do |v|
            document(shape, v, errors, context)
          end
        end
      end

      # rubocop:disable Metrics
      def shape(shape, value, errors, context)
        case shape
        when StructureShape then structure(shape, value, errors, context)
        when ListShape then list(shape, value, errors, context)
        when MapShape then map(shape, value, errors, context)
        when DocumentShape then document(shape, value, errors, context)
        when UnionShape then union(shape, value, errors, context)
        when StringShape, EnumShape
          errors << expected_got(context, 'a String', value) unless value.is_a?(String)
        when IntegerShape, IntEnumShape
          errors << expected_got(context, 'an Integer', value) unless value.is_a?(Integer)
        when FloatShape
          errors << expected_got(context, 'a Float', value) unless value.is_a?(Float)
        when TimestampShape
          errors << expected_got(context, 'a Time object', value) unless value.is_a?(Time)
        when BooleanShape
          errors << expected_got(context, 'true or false', value) unless [true, false].include?(value)
        when BlobShape
          unless value.is_a?(String)
            if streaming_input?(shape)
              unless io_like?(value)
                errors << expected_got(
                  context,
                  'a String or IO like object that supports read and rewind',
                  value
                )
              end
            elsif !io_like?(value, require_size: true)
              errors << expected_got(
                context,
                'a String or IO like object that supports read, rewind, and size',
                value
              )
            end
          end
        else
          raise "unhandled shape type: #{shape.class.name}"
        end
      end
      # rubocop:enable Metrics

      def validate_required_members(structure_shape, values, errors, context)
        structure_shape.members.each do |name, member_shape|
          next unless member_shape.traits.include?('smithy.api#required')

          if values[name].nil?
            param = "#{context}[#{name.inspect}]"
            errors << "missing required parameter #{param}"
          end
        end
      end

      def streaming_input?(shape)
        shape.traits.include?('smithy.api#streaming')
      end

      def io_like?(value, require_size: false)
        value.respond_to?(:read) && value.respond_to?(:rewind) &&
          (!require_size || value.respond_to?(:size))
      end

      def error_messages(errors)
        if errors.size == 1
          errors.first
        else
          prefix = "\n  - "
          "parameter validator found #{errors.size} errors:" +
            prefix + errors.join(prefix)
        end
      end

      def expected_got(context, expected, got)
        format(EXPECTED_GOT, context, expected, got.class.name)
      end
    end
  end
end
