# frozen_string_literal: true

module Smithy
  module Model
    # Represents a shape from the model.
    # Shape IDs have the following syntax:
    #
    # smithy.example.foo#ExampleShapeName$memberName
    # └─────────┬──────┘ └───────┬──────┘ └────┬───┘
    #      (Namespace)     (Shape name)  (Member name)
    #                    └──────────────┬────────────┘
    #                          (Relative shape ID)
    # └──────────────────────┬───────────────────────┘
    #               (Absolute shape ID)
    class Shape
      # Optional shape namespace
      # @param [String] id Shape ID
      # @return [String, nil] Shape namespace
      def self.namespace(id)
        return nil unless id.include?('#')

        id.split('#').first
      end

      # Relative shape ID
      # @param [String] id Shape ID
      # @return [String, nil] Relative shape ID
      def self.relative_id(id)
        id.split('#').last
      end

      # Shape name
      # @param [String] id Shape ID
      # @return [String, nil] Shape name
      def self.name(id)
        id.split('#').last&.split('$')&.first
      end

      # Optional member name
      # @param [String] id Shape ID
      # @return [String, nil] Member name
      def self.member_name(id)
        return nil unless id.include?('$')

        id.split('$').last
      end
    end
  end
end
