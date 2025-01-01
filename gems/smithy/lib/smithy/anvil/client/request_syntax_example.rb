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
          input = @shapes[@operation['input']['target']]
          return docstrings << example unless input['members'].any?

          docstrings + ["#{example}("] + struct(input, '    ', Set.new) + ['  )']
        end

        private

        def struct(shape, indent, visited)
          lines = ["#{indent}{"]
          shape['members'].each do |member_name, member_shape|
            lines << struct_member(member_name, member_shape, indent, visited)
          end
          lines << "#{indent}}"
        end

        def struct_member(member_name, member_shape, indent, visited)
          entry = "#{indent}  #{member_name.underscore}: #{target_value(member_shape, "#{indent}  ", visited)},"
          required = member_shape['traits']&.any? { |k, _| k == 'smithy.api#required' }
          apply_comments(entry, { required: required })
        end

        def target_value(member_shape, indent, visited)
          if visited.include?(member_shape['target'])
            return "{\n#{indent}  # recursive #{member_shape['target']}\n#{indent}}"
          end

          visited << member_shape['target']
          shape = @shapes[member_shape['target']]
          case shape['type']
          when 'structure' then struct(shape, indent, visited)
          when 'string' then Vise::Shape.name(member_shape['target'])
          when 'integer' then '1'
          else raise "unsupported shape #{shape['type'].inspect}"
          end
        end

        def apply_comments(entry, options = {})
          lines = entry.lines.to_a
          if lines[0].match(/\n$/)
            lines[0] = lines[0].sub(/\n$/, "#{comments(options)}\n")
          else
            lines[0] += comments(options)
          end
          lines.join
        end

        def comments(options = {})
          comments = []
          comments << 'required' if options[:required]
          comments == [] ? '' : " # #{comments.join(', ')}"
        end
      end
    end
  end
end
