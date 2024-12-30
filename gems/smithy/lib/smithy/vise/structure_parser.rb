# frozen_string_literal: true

module Smithy
  module Vise
    # @api private
    class StructureParser
      PRELUDE_SHAPES = %w[
        smithy.api#BigInteger
        smithy.api#BigDecimal
        smithy.api#Blob
        smithy.api#Boolean
        smithy.api#Byte
        smithy.api#Document
        smithy.api#Double
        smithy.api#Float
        smithy.api#Integer
        smithy.api#Long
        smithy.api#PrimitiveBoolean
        smithy.api#PrimitiveByte
        smithy.api#PrimitiveDouble
        smithy.api#PrimitiveFloat
        smithy.api#PrimitiveInteger
        smithy.api#PrimitiveLong
        smithy.api#PrimitiveShort
        smithy.api#Short
        smithy.api#String
        smithy.api#Timestamp
        smithy.api#Unit
      ].freeze

      def initialize(model)
        @shapes = model['shapes']
      end

      def shapes_for(structure)
        shapes = {}
        _id, structure = structure.first
        structure['members']&.each_value { |member| parse_member(member, shapes) }
        shapes
      end

      private

      def parse_member(member_ref, shapes)
        target = member_ref['target']
        return if PRELUDE_SHAPES.include?(target)

        shape = @shapes[target]
        shapes[target] = shape
        shape['members']&.each_value { |member| parse_member(member, shapes) }
      end
    end
  end
end
