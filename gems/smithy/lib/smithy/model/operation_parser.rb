# frozen_string_literal: true

module Smithy
  module Model
    # @api private
    class OperationParser
      def initialize(model)
        @model = model
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

      def parse_input_output(structure_shape, shapes)
        target = structure_shape['target']
        return if target == 'smithy.api#Unit'

        shape = Model.shape(@model, target)
        shapes[target] = shape
        shapes.merge!(@structure_parser.shapes_for({ target => shape }))
      end

      def parse_errors(errors, shapes)
        errors&.each do |error|
          target = error['target']
          shape = Model.shape(@model, target)
          shapes[target] = shape
          shapes.merge!(@structure_parser.shapes_for({ target => shape }))
        end
      end
    end
  end
end
