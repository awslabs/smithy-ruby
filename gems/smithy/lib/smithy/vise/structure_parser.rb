# frozen_string_literal: true

module Smithy
  module Vise
    # @api private
    class StructureParser
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
        return if Vise::PRELUDE_SHAPES.include?(target)

        shape = @shapes[target]
        shapes[target] = shape
        visited[target] = true
        shape['members']&.each_value { |member| parse_member(member, shapes, visited) }
      end
    end
  end
end
