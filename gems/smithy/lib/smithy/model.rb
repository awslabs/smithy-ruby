# frozen_string_literal: true

require_relative 'model/flattener'
require_relative 'model/rbs'
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

    # @param [Hash] model Model
    # @param [String] id Shape ID
    # @return [Hash]
    def self.shape(model, id)
      if model['shapes'].key?(id)
        Flattener.new(model).flatten_shape(id, model['shapes'][id])
      elsif PRELUDE_SHAPES.key?(id)
        PRELUDE_SHAPES[id]
      else
        raise ArgumentError, "Shape not found: #{id}"
      end
    end
  end
end
