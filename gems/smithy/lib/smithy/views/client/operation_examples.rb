# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class OperationExamples
        # @param [Model] model Model
        # @param [String] operation_name Operation name
        # @param [Hash<String, Object>] operation Operation shape
        def initialize(model, operation_name, operation)
          @model = model
          @operation_name = operation_name
          @operation = operation
          @examples = operation.fetch('traits', {}).fetch('smithy.api#examples', [])
        end

        def docstrings
          examples = ''
          @examples.each do |example|
            examples += example(example)
          rescue ArgumentError => e
            puts "Error processing example for #{@operation_name}: #{e}"
            next
          end
          examples.split("\n")
        end

        private

        def example(example)
          if example['error']
            error_example(example)
          else
            output_example(example)
          end
        end

        def output_example(example)
          <<~EXAMPLE
            @example #{example['title']}
              #{description(example)}
              params = #{params(example['input'], @operation['input']['target'])}
              options = {}
              output = client.#{@operation_name}(params, options)
              output.to_h #=>
              #{params(example['output'], @operation['output']['target'])}
          EXAMPLE
        end

        def error_example(example)
          error = example['error']
          <<~EXAMPLE
            @example #{example['title']}
              #{description(example)}
              params = #{params(example['input'], @operation['input']['target'])}
              options = {}
              begin
                output = client.#{@operation_name}(params, options)
              rescue Smithy::Client::Errors::ServiceError => e
                puts e.class #=> #{Model::Shape.name(error['shapeId'])}
                puts e.data.to_h #=>
                #{error_data(error['content'], error['shapeId'])}
              end
          EXAMPLE
        end

        def params(document, target, indent = '  ')
          shape = Model.shape(@model, target)
          structure(document, shape, indent).join("\n")
        end

        def error_data(document, shape_id, indent = '    ')
          shape = Model.shape(@model, shape_id)
          structure(document, shape, indent).join("\n")
        end

        def description(example)
          description = example.fetch('description', "Example operation for #{@operation_name}")
          description.split("\n").map { |line| "# #{line}" }.join("\n")
        end

        def value(json, shape, indent)
          case shape['type']
          when 'structure' then structure(json, shape, indent)
          when 'map' then map(json, shape, indent)
          when 'list' then list(json, shape, indent)
          when 'timestamp' then "Time.parse(#{json.inspect})"
          when 'string', 'blob' then json.inspect
          else json
          end
        end

        def structure(json, shape, indent)
          lines = []
          lines << '{'
          json.each_pair do |key, value|
            member_shape = Model.shape(@model, shape['members'][key]['target'])
            entry = value(value, member_shape, "#{indent}  ")
            lines << "#{indent}  #{key.underscore}: #{format(entry)},"
          end
          lines.last.chomp!(',')
          lines << "#{indent}}"
          lines
        end

        def map(json, shape, indent)
          lines = []
          lines << '{'
          json.each do |key, value|
            member_shape = Model.shape(@model, shape['value']['target'])
            entry = value(value, member_shape, "#{indent}  ")
            lines << "#{indent}  \"#{key}\" => #{format(entry)},"
          end
          lines.last.chomp!(',')
          lines << "#{indent}}"
          lines
        end

        def list(json, shape, indent)
          lines = []
          lines << '['
          json.each do |element|
            member_shape = Model.shape(@model, shape['member']['target'])
            entry = value(element, member_shape, "#{indent}  ")
            lines << "#{indent}  #{format(entry)},"
          end
          lines.last.chomp!(',')
          lines << "#{indent}]"
          lines
        end

        def format(shape_val)
          formatted = []
          if shape_val.is_a?(Array)
            hashes = shape_val.map do |v|
              (v.is_a?(Hash) ? format_hash(v, '  ') : v)
            end
            hashes.join(',')
            formatted << hashes
          elsif shape_val.is_a?(Hash)
            formatted << format_hash(shape_val, '  ')
          else
            formatted << shape_val
          end
          formatted.join("\n")
        end

        def format_hash(value, indent)
          Util::HashFormatter.new(indent: indent).format(value)
        end
      end
    end
  end
end
