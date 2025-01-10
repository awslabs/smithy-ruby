# frozen_string_literal: true

module Smithy
  module Model
    # @api private
    class ServiceParser
      RESOURCE_LIFECYCLE_KEYS = %w[create put read update delete list].freeze

      def initialize(model)
        @model = model
      end

      def operations_for(service)
        operations = {}
        _id, service = service.first
        parse_service_operations(service, operations)
        parse_service_resources(service, operations)
        operations
      end

      private

      def parse_service_operations(service, operations)
        service['operations']&.collect do |shape|
          target = shape['target']
          operations[target] = Model.shape(@model, target)
        end
      end

      def parse_service_resources(service, operations)
        service['resources']&.collect do |shape|
          target = shape['target']
          resource_shape = Model.shape(@model, target)
          parse_resource(resource_shape, operations)
        end
      end

      def parse_resource(resource, operations)
        parse_lifecycles(resource, operations)
        parse_resource_operations(resource, operations)
        parse_resource_collection_operations(resource, operations)

        resource['resources']&.collect do |shape|
          target = shape['target']
          resource_shape = Model.shape(@model, target)
          parse_resource(resource_shape, operations)
        end
      end

      def parse_lifecycles(resource, operations)
        RESOURCE_LIFECYCLE_KEYS.each do |key|
          next unless resource[key]

          target = resource[key]['target']
          operations[target] = Model.shape(@model, target)
        end
      end

      def parse_resource_operations(resource, operations)
        resource['operations']&.collect do |shape|
          target = shape['target']
          operations[target] = Model.shape(@model, target)
        end
      end

      def parse_resource_collection_operations(resource, operations)
        resource['collectionOperations']&.collect do |shape|
          target = shape['target']
          operations[target] = Model.shape(@model, target)
        end
      end
    end
  end
end
