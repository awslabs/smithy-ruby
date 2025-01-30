# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class RequestResponseExample
        # @param [Hash] model Model
        # @param [String] operation_name Operation name
        # @param [Hash<String, Object>] operation Operation shape
        def initialize(model, operation_name, operation)
          @model = model
          @operation_name = operation_name
          @operation = operation
        end

        def docstrings
          example = <<~EXAMPLE
            @example Request syntax with placeholder values
              params = #{request_params}
              options = {}
              output = client.#{@operation_name}(params, options)
            @example Response structure with placeholder values
              output.to_h #=>
              #{response_hash}
          EXAMPLE
          example.split("\n")
        end

        private

        def request_params
          target = @operation['input']['target']
          return '{}' if target == 'smithy.api#Unit'

          input = Model.shape(@model, target)
          return '{}' unless input['members'].any?

          structure(input, '  ', Set.new)
        end

        def response_hash
          target = @operation['output']['target']
          return '{}' if target == 'smithy.api#Unit'

          output = Model.shape(@model, target)
          return '{}' unless output['members'].any?

          structure(output, '  ', Set.new)
        end

        # rubocop:disable Metrics
        def value(target, indent, visited)
          if visited.include?(target)
            shape = Model::Shape.name(target)
            return "{\n#{indent}  # recursive #{shape}\n#{indent}}"
          end

          visited += [target]
          shape = Model.shape(@model, target)

          case shape['type']
          when 'blob' then blob(shape)
          when 'boolean' then 'false'
          when 'string' then string(target)
          when 'byte' then '97'
          when 'short', 'integer', 'long', 'bigInteger' then '1'
          when 'float', 'double' then '1.0'
          when 'bigDecimal' then 'BigDecimal(1)'
          when 'timestamp' then 'Time.now'
          when 'document' then 'TODO: document'
          when 'enum' then enum(shape)
          when 'intEnum' then enum(shape, string: false)
          when 'list' then list(shape, indent, visited)
          when 'map' then map(shape, indent, visited)
          when 'structure' then structure(shape, indent, visited)
          when 'union' then union(shape, indent, visited)
          else raise "unsupported shape type: #{shape['type'].inspect}"
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
          Model::Shape.name(target).inspect
        end

        def enum(shape, string: true)
          enum_values = shape['members'].map do |_, member_shape|
            value = member_shape['traits']['smithy.api#enumValue']
            string ? "\"#{value}\"" : value
          end
          "#{enum_values.first} # One of: [#{enum_values.join(', ')}]"
        end

        def structure(structure_shape, indent, visited)
          lines = []
          lines << '{'
          structure_shape['members']&.each_pair do |member_name, member_shape|
            lines << member(member_name, member_shape, indent, visited)
          end
          lines.last.chomp!(',') if lines.last.end_with?(',')
          lines << "#{indent}}"
          lines.join("\n")
        end

        def union(union_shape, indent, visited)
          lines = []
          lines << '{'
          lines << "#{indent}  # One of:"
          union_shape['members']&.each_pair do |member_name, member_shape|
            lines << member(member_name, member_shape, indent, visited)
          end
          lines.last.chomp!(',') if lines.last.end_with?(',')
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
          shape = Model.shape(@model, member_shape['target'])
          %w[structure list map].include?(shape['type'])
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
