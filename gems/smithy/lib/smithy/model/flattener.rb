# frozen_string_literal: true

module Smithy
  module Model
    # @api private
    class Flattener
      def initialize(model)
        @model = model
      end

      def flatten_shape(id, shape)
        mixin_members, mixin_traits = resolve_mixins(shape)

        shape['members'] = mixin_members.merge(shape.fetch('members', {})) unless mixin_members.empty?
        shape['traits'] = merge2(mixin_traits, shape.fetch('traits', {})) unless mixin_traits.empty?

        # after mixins are done, then check for any "apply" for any members
        flatten_apply_traits(id, shape)

        shape
      end

      private

      def flatten_apply_traits(id, shape)
        shape.fetch('members', {}).each_key do |name|
          # check for an apply
          member_id = "#{id}$#{name}"
          next unless @model['shapes'][member_id] && @model['shapes'][member_id]['type'] == 'apply'

          flatten_apply_trait(shape, name, member_id)
        end
      end

      def flatten_apply_trait(shape, name, member_id)
        shape['members'][name]['traits'] =
          shape['members'][name].fetch('traits', {}).merge(@model['shapes'][member_id]['traits'])
      end

      def resolve_mixins(shape)
        mixin_traits = {}
        mixin_members = {}
        shape.fetch('mixins', []).each do |mixin|
          mixin_shape = flatten_shape(mixin['target'], @model['shapes'][mixin['target']])
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
