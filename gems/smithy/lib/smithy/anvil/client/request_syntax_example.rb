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
          @method_name = Vise::Shape.name(id).underscore
          @operation = operation
        end

        def docstrings
          example = <<~EXAMPLE
            @example Request syntax with placeholder values

              params = #{request_params}
              options = {}
              output = client.#{@method_name}(params, options)
          EXAMPLE
          example.split("\n")
        end

        private

        def request_params
          target = @operation['input']['target']
          return '{}' if target == 'smithy.api#Unit'

          input = @shapes[target]
          return '{}' unless input['members'].any?

          struct(input, '  ', Set.new)
        end

        # rubocop:disable Metrics
        def value(target, indent, visited)
          if visited_shape?(target, visited)
            shape = Vise::Shape.name(target)
            return "{\n#{indent}  # recursive #{shape}\n#{indent}}"
          end

          visited += [target]
          shape = @shapes[target]
          type_or_target = (shape['type'] if shape) || target

          case type_or_target
          when 'blob', 'smithy.api#Blob' then blob(shape)
          when 'boolean', 'smithy.api#Boolean' then 'false'
          when 'string', 'smithy.api#String' then string(target)
          when 'byte', 'smithy.api#Byte' then '97'
          when 'short', 'smithy.api#Short', 'integer', 'smithy.api#Integer',
               'long', 'smithy.api#Long', 'bigInteger', 'smithy.api#BigInteger' then '1'
          when 'float', 'smithy.api#Float', 'double', 'smithy.api#Double' then '1.0'
          when 'bigDecimal', 'smithy.api#BigDecimal' then 'BigDecimal(1)'
          when 'timestamp', 'smithy.api#Timestamp' then 'Time.now'
          when 'document', 'smithy.api#Document' then 'TODO: document'
          when 'enum' then enum(shape)
          when 'intEnum' then enum(shape, string: false)
          when 'list' then list(shape, indent, visited)
          when 'map' then map(shape, indent, visited)
          when 'structure' then struct(shape, indent, visited)
          when 'union' then 'TODO: union'
          else raise "unsupported type or target: #{type_or_target}"
          end
        end
        # rubocop:enable Metrics

        def blob(shape)
          if shape && shape['traits']&.include?('smithy.api#streaming')
            'File.read("source_file")'
          else
            '"data"'
          end
        end

        def string(target)
          Vise::Shape.name(target).inspect
        end

        def enum(shape, string: true)
          enum_values = shape['members'].map do |_, member_shape|
            value = member_shape['traits']['smithy.api#enumValue']
            string ? "\"#{value}\"" : value
          end
          "#{enum_values.first} # One of: [#{enum_values.join(', ')}]"
        end

        def visited_shape?(target, visited)
          # Prelude shapes are used more than once usually
          !Vise::PRELUDE_SHAPES.include?(target) && visited.include?(target)
        end

        def struct(struct_shape, indent, visited)
          lines = []
          lines << '{'
          struct_shape['members']&.each_pair do |member_name, member_shape|
            lines << member(member_name, member_shape, indent, visited)
          end
          lines.last.chomp!(',')
          lines << "#{indent}}"
          lines.join("\n")
        end

        def member(member_name, member_shape, indent, visited)
          value = value(member_shape['target'], "#{indent}  ", visited)
          entry = "#{indent}  #{member_name.underscore}: #{value},"
          apply_comments(member_shape, entry)
        end

        def list(list_shape, indent, visited)
          member_shape = list_shape['member']
          if complex?(member_shape)
            complex_list(member_shape, indent, visited)
          else
            scalar_list(member_shape, indent, visited)
          end
        end

        def complex?(member_shape)
          return false if Vise::PRELUDE_SHAPES.include?(member_shape['target'])

          s = @shapes[member_shape['target']]
          s['type'] == 'structure' || s['type'] == 'list' || s['type'] == 'map'
        end

        def scalar_list(member_shape, indent, visited)
          "[#{value(member_shape['target'], indent, visited)}]"
        end

        def complex_list(member_shape, indent, visited)
          "[\n#{indent}  #{value(member_shape['target'], "#{indent}  ", visited)}\n#{indent}]"
        end

        def map(map_shape, indent, visited)
          key = string(map_shape['key']['target'])
          value = value(map_shape['value']['target'], "#{indent}  ", visited)
          "{\n#{indent}  #{key} => #{value}\n#{indent}}"
        end

        def apply_comments(shape, text)
          lines = text.lines.to_a
          if lines[0].match(/\n$/)
            lines[0] = lines[0].sub(/\n$/, "#{comments(shape)}\n")
          else
            lines[0] += comments(shape)
          end
          lines.join
        end

        def comments(shape)
          required = shape['traits']&.any? { |k, _| k == 'smithy.api#required' }
          comments = []
          comments << 'required' if required
          comments == [] ? '' : " # #{comments.join(', ')}"
        end
      end
    end
  end
end
