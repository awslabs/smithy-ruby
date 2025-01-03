# frozen_string_literal: true

module Smithy
  module Vise
    # Finds sets of shapes for a service.
    class ServiceIndex
      # @param [Hash] model Model
      def initialize(model)
        @shapes = model['shapes']
        @service_parser = ServiceParser.new(model)
        @operation_parser = OperationParser.new(model)
        @structure_parser = StructureParser.new(model)
      end

      # @param [Hash] service Service shape
      # @return [Hash<String, Hash>] The operations for the service.
      def operations_for(service)
        @operations_for ||= begin
          shapes = @service_parser.operations_for(service)
          shapes.sort_by { |k, _v| k }.to_h
        end
      end

      # @param [Hash] service Service shape
      # @return [Hash<String, Hash>] The shapes for the service.
      def shapes_for(service)
        @shapes_for ||= begin
          shapes = {}
          parse_errors(service, shapes)
          operations_for(service).each do |id, operation|
            shapes.merge!(@operation_parser.shapes_for({ id => operation }))
          end
          shapes.sort_by { |k, _v| k }.to_h
        end
      end

      private

      def parse_errors(service, shapes)
        _, service = service.first

        service['errors']&.each do |error_ref|
          target = error_ref['target']
          shape = @shapes[target]
          shapes[target] = shape
          shapes.merge!(@structure_parser.shapes_for({ target => shape }))
        end
      end
    end
  end
end
