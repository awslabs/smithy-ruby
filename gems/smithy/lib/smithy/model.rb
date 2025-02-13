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

    class << self
      # @param [Hash] model Model
      # @param [String] target Target shape
      # @return [Hash] The shape
      def shape(model, target)
        if model['shapes'].key?(target)
          flatten_shape(target, model, model['shapes'][target])
        elsif PRELUDE_SHAPES.key?(target)
          PRELUDE_SHAPES[target]
        else
          raise ArgumentError, "Shape not found: #{target}"
        end
      end

      private

      def flatten_shape(id, model, shape)
        mixin_members, mixin_traits = resolve_mixins(model, shape)

        shape['members'] = mixin_members.merge(shape.fetch('members', {})) unless mixin_members.empty?
        shape['traits'] = merge2(mixin_traits, shape.fetch('traits', {})) unless mixin_traits.empty?

        shape.delete('mixins') # remove mixins now that we've resolved them all

        # after mixins are done, then check for any "apply" for any members
        flatten_apply_traits(id, model, shape)

        shape
      end

      def flatten_apply_traits(id, model, shape)
        shape.fetch('members', {}).each_key do |name|
          # check for an apply
          member_id = "#{id}$#{name}"
          next unless model['shapes'][member_id] && model['shapes'][member_id]['type'] == 'apply'

          flatten_apply_trait(model, shape, name, member_id)
        end
      end

      def flatten_apply_trait(model, shape, name, member_id)
        shape['members'][name]['traits'] =
          shape['members'][name].fetch('traits', {}).merge(model['shapes'][member_id]['traits'])

        model['shapes'].delete(member_id)
      end

      def resolve_mixins(model, shape)
        mixin_traits = {}
        mixin_members = {}
        shape.fetch('mixins', []).each do |mixin|
          mixin_shape = flatten_shape(mixin['target'], model, model['shapes'][mixin['target']])
          mixin_members = mixin_members.merge(mixin_shape['members']) if mixin_shape['members']

          next unless mixin_shape['traits']

          mixin_traits = resolve_mixin_traits(mixin_shape, mixin_traits)
        end

        [mixin_members, mixin_traits]
      end

      def resolve_mixin_traits(mixin_shape, mixin_traits)
        skip_traits = mixin_shape['traits'].fetch('smithy.api#mixin', {}).fetch('localTraits', [])
        skip_traits << 'smithy.api#mixin'
        merge2(
          mixin_traits,
          mixin_shape['traits'].except(*skip_traits)
        )
      end

      # A variant of Hash.merge that places keys from hash2 first rather than last
      # Order of precedence is the same as Hash.merge.
      # values from hash2 are used over values from hash1.
      # Keys in hash2 are first in the resulting hash.
      def merge2(hash1, hash2)
        result = {}
        hash2.each do |key, value|
          result[key] = value
        end
        hash1.each do |key, value|
          result[key] = value unless result.key?(key)
        end
        result
      end
    end
  end
end
