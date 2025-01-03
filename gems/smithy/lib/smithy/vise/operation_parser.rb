# frozen_string_literal: true

module Smithy
  module Vise
    # @api private
    class OperationParser
      def initialize(model)
        @shapes = model['shapes']
        @structure_parser = StructureParser.new(model)
      end

      def shapes_for(operation)
        shapes = {}
        _id, operation = operation.first
        parse_input_output(operation['input'], shapes)
        parse_input_output(operation['output'], shapes)
        parse_errors(operation['errors'], shapes)
        shapes
      end

      private

      def parse_input_output(shape_ref, shapes)
        target = shape_ref['target']
        return if target == 'smithy.api#Unit'

        shape = @shapes[target]
        shapes[target] = shape
        shapes.merge!(@structure_parser.shapes_for({ target => shape }))
      end

      def parse_errors(errors, shapes)
        errors&.each do |error_ref|
          target = error_ref['target']
          shape = @shapes[target]
          shapes[target] = shape
          shapes.merge!(@structure_parser.shapes_for({ target => shape }))
        end
      end
    end
  end
end
