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

      def parse_member(member_ref, shapes)
        target = member_ref['target']
        return if shapes.key?(target)

        shape = Model.shape(@model, target)
        shapes[target] = shape
        parse_members(shape, shapes)
      end

      def parse_members(shape, shapes)
        case shape['type']
        when 'list'
          parse_member(shape['member'], shapes)
        when 'map'
          parse_member(shape['key'], shapes)
          parse_member(shape['value'], shapes)
        else
          # covers all other shapes including structure, union, enum
          shape['members']&.each_value { |member| parse_member(member, shapes) }
        end
      end
    end
  end
end
