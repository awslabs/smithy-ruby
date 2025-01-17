# frozen_string_literal: true

require_relative 'model/shape'
require_relative 'model/operation_parser'
require_relative 'model/service_index'
require_relative 'model/service_parser'
require_relative 'model/structure_parser'

module Smithy
  # A module that parses the Smithy JSON model.
  module Model
    # Generated with smithy-cli 1.53.0
    # @api private
    PRELUDE_SHAPES = {
      'smithy.api#BigInteger' => { 'type' => 'bigInteger' },
      'smithy.api#BigDecimal' => { 'type' => 'bigDecimal' },
      'smithy.api#Blob' => { 'type' => 'blob' },
      'smithy.api#Boolean' => { 'type' => 'boolean' },
      'smithy.api#Byte' => { 'type' => 'byte' },
      'smithy.api#Document' => { 'type' => 'document' },
      'smithy.api#Double' => { 'type' => 'double' },
      'smithy.api#Float' => { 'type' => 'float' },
      'smithy.api#Integer' => { 'type' => 'integer' },
      'smithy.api#Long' => { 'type' => 'long' },
      'smithy.api#PrimitiveBoolean' => { 'type' => 'boolean', 'traits' => { 'smithy.api#default' => false } },
      'smithy.api#PrimitiveByte' => { 'type' => 'byte', 'traits' => { 'smithy.api#default' => 0 } },
      'smithy.api#PrimitiveDouble' => { 'type' => 'double', 'traits' => { 'smithy.api#default' => 0 } },
      'smithy.api#PrimitiveFloat' => { 'type' => 'float', 'traits' => { 'smithy.api#default' => 0 } },
      'smithy.api#PrimitiveInteger' => { 'type' => 'integer', 'traits' => { 'smithy.api#default' => 0 } },
      'smithy.api#PrimitiveLong' => { 'type' => 'long', 'traits' => { 'smithy.api#default' => 0 } },
      'smithy.api#PrimitiveShort' => { 'type' => 'short', 'traits' => { 'smithy.api#default' => 0 } },
      'smithy.api#Short' => { 'type' => 'short' },
      'smithy.api#String' => { 'type' => 'string' },
      'smithy.api#Timestamp' => { 'type' => 'timestamp' },
      'smithy.api#Unit' => { 'type' => 'structure', 'members' => {}, 'traits' => { 'smithy.api#unitType' => {} } }
    }.freeze

    class << self
      # @param [Hash] model Model
      # @param [String] target Target shape
      # @return [Hash] The shape
      def shape(model, target)
        if model['shapes'].key?(target)
          model['shapes'][target]
        elsif PRELUDE_SHAPES.key?(target)
          PRELUDE_SHAPES[target]
        else
          raise ArgumentError, "Shape not found: #{target}"
        end
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      def rbs_type(model, id, shape)
        case shape['type']
        when 'blob', 'string', 'enum' then 'String'
        when 'boolean' then 'bool'
        when 'byte', 'short', 'integer', 'long', 'intEnum' then 'Integer'
        when 'float', 'double' then 'Float'
        when 'timestamp' then 'Time'
        when 'document' then 'Hash' # TODO
        when 'list'
          rbs_list_type(model, shape)
        when 'map'
          rbs_map_type(model, shape)
        when 'structure', 'union'
          "Types::#{Model::Shape.name(id)}"
        else
          'untyped'
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      private

      def rbs_map_type(model, shape)
        key_target = Model.shape(model, shape['key']['target'])
        value_target = Model.shape(model, shape['value']['target'])
        sparse = shape.fetch('traits', {}).key?('smithy.api#sparse')
        key_type = rbs_type(model, shape['key']['target'], key_target)
        value_type = rbs_type(model, shape['value']['target'], value_target)
        "Hash[#{key_type}, #{value_type}#{'?' if sparse}]"
      end

      def rbs_list_type(model, shape)
        member_target = Model.shape(model, shape['member']['target'])
        sparse = shape.fetch('traits', {}).key?('smithy.api#sparse')
        "Array[#{rbs_type(model, shape['member']['target'], member_target)}#{'?' if sparse}]"
      end
    end
  end
end
