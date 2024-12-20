# frozen_string_literal: true

module Smithy
  module Vise
    # Finds a service shape in a set of shapes.
    class ServiceIndex
      # @param [Hash] model Model
      def initialize(model)
        @service = find_service(model['shapes'])
      end

      # @return [Hash<String, Hash>] The service shape for the shapes.
      attr_reader :service

      private

      def find_service(shapes)
        service = shapes.select { |_, shape| shape['type'] == 'service' }
        raise 'Multiple service shapes found' if service.size > 1
        raise 'No service shape found' if service.empty?

        service
      end
    end
  end
end
