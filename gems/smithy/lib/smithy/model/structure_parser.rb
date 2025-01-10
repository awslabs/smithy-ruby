# frozen_string_literal: true

module Smithy
  module Model
    # @api private
    class StructureParser
      def initialize(model)
        @model = model
      end

      def shapes_for(structure)
        shapes = {}
        _id, structure = structure.first
        structure['members']&.each_value { |member| parse_member(member, shapes) }
        shapes
      end

      private

      def parse_member(member_shape, shapes)
        target = member_shape['target']
        return if shapes.key?(target)
        return if Model::PRELUDE_SHAPES.key?(target)

        shape = Model.shape(@model, target)
        shapes[target] = shape
        parse_shape(shape, shapes)
      end

      def parse_shape(shape, shapes)
        case shape['type']
        when 'list'
          parse_member(shape['member'], shapes)
        when 'map'
          parse_member(shape['key'], shapes)
          parse_member(shape['value'], shapes)
        when 'structure', 'union', 'intEnum', 'enum'
          shape['members']&.each_value { |member| parse_member(member, shapes) }
        end
      end
    end
  end
end
