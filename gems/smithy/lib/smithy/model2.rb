# frozen_string_literal: true

require_relative 'shapes'

module Smithy
  class Model2
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
    def initialize(model)
      @model = model
      @shapes = {}
      visit(model)
    end

    attr_reader :shapes

    private

    def visit(model)
      model['shapes'].each do |id, shape|
        shape(id, shape)
      end
    end

    def structure(id, shape)
      structure = @shapes[id] = Smithy::Shapes::StructureShape.new(id: id, traits: shape['traits'])
      shape['members'].each do |member_name, member_shape|
        target = member_shape['target']
        member = shape(target, @model['shapes'][target])
        structure.add_member(member_name, member, traits: member_shape['traits'])
      end
      structure
    end

    def string(id, shape)
      @shapes[id] = Smithy::Shapes::StringShape.new(id: id, traits: shape['traits'])
    end

    def shape(id, shape)
      return @shapes[id] if @shapes.key?(id)

      shape = PRELUDE_SHAPES[id] if PRELUDE_SHAPES.key?(id)
      case shape['type']
      when 'structure' then structure(id, shape)
      when 'string' then string(id, shape)
      end
    end

  end
end