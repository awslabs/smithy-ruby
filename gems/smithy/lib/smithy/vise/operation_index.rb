# frozen_string_literal: true

module Smithy
  module Vise
    # Finds all operation shapes in a service.
    class OperationIndex
      RESOURCE_LIFECYCLE_KEYS = %w[create put read update delete list].freeze

      # @param [Hash] model Model
      def initialize(model)
        @shapes = model['shapes']
      end

      # @param [Hash] service Service shape
      # @return [Hash<String, Hash>] The operations for the service.
      def for(service)
        operations = {}
        _id, service = service.first
        parse_service_operations(service, operations)
        parse_service_resources(service, operations)
        operations.sort_by { |k, _v| k }.to_h
      end

      private

      def parse_service_operations(service, operations)
        service['operations']&.collect do |shape|
          id = shape['target']
          operations[id] = @shapes[id]
        end
      end

      def parse_service_resources(service, operations)
        service['resources']&.collect do |shape|
          id = shape['target']
          parse_resource(@shapes[id], operations)
        end
      end

      def parse_resource(resource, operations)
        parse_lifecycles(resource, operations)
        parse_resource_operations(resource, operations)
        parse_resource_collection_operations(resource, operations)

        resource['resources']&.collect do |shape|
          id = shape['target']
          parse_resource(@shapes[id], operations)
        end
      end

      def parse_lifecycles(resource, operations)
        RESOURCE_LIFECYCLE_KEYS.each do |key|
          next unless resource[key]

          id = resource[key]['target']
          operations[id] = @shapes[id]
        end
      end

      def parse_resource_operations(resource, operations)
        resource['operations']&.collect do |shape|
          id = shape['target']
          operations[id] = @shapes[id]
        end
      end

      def parse_resource_collection_operations(resource, operations)
        resource['collectionOperations']&.collect do |shape|
          id = shape['target']
          operations[id] = @shapes[id]
        end
      end
    end
  end
end
