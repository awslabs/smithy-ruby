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

      def shapes_for(structure, visited = {})
        shapes = {}
        _id, structure = structure.first
        structure['members']&.each_value { |member| parse_member(member, shapes, visited) }
        shapes
      end

      private

      def parse_member(member_ref, shapes, visited)
        target = member_ref['target']
        return if visited.include?(target)
        return if PRELUDE_SHAPES.include?(target)

        shape = @shapes[target]
        shapes[target] = shape
        visited[target] = true
        parse_members(shape, shapes, visited)
      end

      def parse_members(shape, shapes, visited)
        case shape['type']
        when 'list'
          parse_member(shape['member'], shapes, visited)
        when 'map'
          parse_member(shape['key'], shapes, visited)
          parse_member(shape['value'], shapes, visited)
        else
          # covers structure, union
          shape['members']&.each_value { |member| parse_member(member, shapes, visited) }
        end
      end
    end
  end
end
