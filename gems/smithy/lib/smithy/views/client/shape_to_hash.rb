# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      module ShapeToHash
        class << self
          def transform_value(model, value, shape)
            return value unless shape && value

            case shape['type']
            when 'structure', 'union'
              transform_structure(model, shape, value)
            when 'list'
              transform_list(model, shape, value)
            when 'map'
              transform_map(model, shape, value)
            else
              value
            end
          end

          private

          def transform_map(model, shape, value)
            member_shape = Model.shape(model, shape['value']['target'])
            value.transform_values do |v|
              transform_value(model, v, member_shape)
            end
          end

          def transform_list(model, shape, value)
            member_shape = Model.shape(model, shape['member']['target'])
            value.map { |v| transform_value(model, v, member_shape) }
          end

          def transform_structure(model, shape, value)
            value.each_with_object({}) do |(k, v), o|
              if shape['members'].nil? || shape['members'][k].nil?
                puts "oh no"
              end
              member_shape = Model.shape(model, shape['members'][k]['target'])
              o[k.underscore.to_sym] = transform_value(model, v, member_shape)
            end
          end
        end
      end
    end
  end
end
