# frozen_string_literal: true

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
    # @param [String] target Target shape
    # @return [Hash] The shape
    def self.shape(model, target)
      if model['shapes'].key?(target)
        model['shapes'][target]
      elsif PRELUDE_SHAPES.key?(target)
        PRELUDE_SHAPES[target]
      else
        raise ArgumentError, "Shape not found: #{target}"
      end
    end

    # resolve mixins and "apply" types.
    def self.preprocess(model)
      # TODO: Deep dup of model
      # handle mixins
      model['shapes'].each do |id, shape|
        flatten_shape(id, model, shape)
      end
      model
    end

    def self.flatten_shape(id, model, shape)
      shape.fetch('mixins', []).each do |mixin|
        mixin_shape = flatten_shape(mixin['target'], model, model['shapes'][mixin['target']])
        shape['members'] = shape.fetch('members', {}).merge(mixin_shape['members']) if mixin_shape['members']

        next unless mixin_shape['traits']

        skip_traits = mixin_shape['traits'].fetch('smithy.api#mixin', {}).fetch('localTraits', [])
        skip_traits << 'smithy.api#mixin'
        shape['traits'] = shape.fetch('traits', {}).merge(
          mixin_shape['traits'].except(*skip_traits)
        )
      end
      shape.delete('mixins') # remove mixins now that we've resolved them all
      # after mixins are done, then check for any "apply" for any members
      shape.fetch('members', {}).each_key do |name|
        # check for an apply
        member_id = "#{id}$#{name}"
        next unless model['shapes'][member_id] && model['shapes'][member_id]['type'] == 'apply'

        shape['members'][name]['traits'] =
          shape['members'][name].fetch('traits', {}).merge(model['shapes'][member_id]['traits'])
        model['shapes'].delete(member_id)
      end
      # finally, ensure correct member and trait orders
      # TODO: Ensure trait and member orders...
      shape
    end

    def self.merge_reorder; end
  end
end
