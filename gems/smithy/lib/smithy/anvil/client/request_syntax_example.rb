# frozen_string_literal: true

module Smithy
  module Anvil
    module Client
      # @api private
      class RequestSyntaxExample
        # @param [Hash] model Model
        # @param [String] id Operation shape ID
        # @param [Hash<String, Object>] operation Operation shape
        def initialize(model, id, operation)
          @shapes = model['shapes']
          @id = id
          @operation = operation
        end

        def docstrings
          docstrings = [
            '@example Request syntax with placeholder values',
            ''
          ]
          example = "  output = client.#{Vise::Shape.name(@id).underscore}"
          target = @operation['input']['target']
          return docstrings << example if target == 'smithy.api#Unit'

          input = @shapes[target]
          return docstrings << example unless input['members'].any?

          docstrings << "#{example}("
          docstrings << struct(input, '    ', Set.new)
          docstrings << '  )'
          docstrings.flatten
        end

        private

        def struct(shape, indent, visited)
          docstrings = ["#{indent}{"]
          shape['members'].each do |member_name, member_shape|
            docstrings << struct_member(member_name, member_shape, indent, visited)
          end
          docstrings << "#{indent}}"
        end

        def struct_member(member_name, member_shape, indent, visited)
          docstrings = []
          target = member_shape['target']
          shape = @shapes[target]

          value = target_value(member_shape, "#{indent}  ", visited)
          if shape && shape['type'] == 'structure'
            docstrings << "#{indent}  #{member_name.underscore}: {#{comments(member_shape)}"
            docstrings << value
            docstrings << "#{indent}  }"
          elsif shape && shape['type'] == 'list'
            # TODO
          elsif shape && shape['type'] == 'map'
            # TODO
          else
            docstrings << "#{indent}  #{member_name.underscore}: #{value}#{comments(member_shape)}"
          end
        end

        def target_value(member_shape, indent, visited)
          if visited.include?(member_shape['target'])
            return [
              '{',
              "#{indent} # recursive #{Vise::Shape.name(member_shape['target'])}",
              '}'
            ]
          end

          target = member_shape['target']
          visited << target
          shape = @shapes[target]
          shape_or_target = (shape['type'] if shape) || target

          case shape_or_target
          # TODO: handle other types
          when 'string', 'smithy.api#String' then Vise::Shape.name(target).inspect
          when 'boolean', 'smithy.api#Boolean' then 'false'
          when 'integer', 'smithy.api#Integer' then '1'
          when 'structure' then struct(shape, "#{indent}  ", visited)
          else raise "unsupported shape or target #{shape_or_target.inspect}"
          end
        end

        def comments(member_shape)
          comments = []
          comments << 'required' if member_shape['traits']&.any? { |k, _| k == 'smithy.api#required' }
          comments == [] ? '' : " # #{comments.join(', ')}"
        end
      end
    end
  end
end
