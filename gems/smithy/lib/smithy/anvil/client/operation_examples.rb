# frozen_string_literal: true

module Smithy
  module Anvil
    module Client
      # @api private
      class OperationExamples
        # @param [String] operation_name Operation name
        # @param [Array<Hash<String, Object>>] examples Examples
        def initialize(operation_name, examples)
          @operation_name = operation_name
          @examples = examples
        end

        def docstrings
          examples = ''
          @examples.each do |example|
            examples += example(example)
          end
          examples.split("\n") << ''
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

              # #{example['description']}
              params = #{format_hash(example['input'])}
              options = {}
              output = client.#{@operation_name}(params, options)
              output.to_h #=>
              #{format_hash(example['output'])}

          EXAMPLE
        end

        def error_example(example)
          error = example['error']
          <<~EXAMPLE
            @example #{example['title']}

              # #{example['description']}
              params = #{format_hash(example['input'])}
              options = {}
              begin
                output = client.#{@operation_name}(params, options)
              rescue Smithy::Client::Errors::ServiceError => e
                puts e.class #=> #{Vise::Shape.name(error['shapeId'])}
                puts e.data.to_h #=>
                #{format_hash(error['content'], '    ')}
              end

          EXAMPLE
        end

        def format_hash(shape, newline_indent = '  ')
          return '{}' unless shape

          json = JSON.pretty_generate(
            underscore_keys(shape),
            object_nl: "\n#{newline_indent}",
            array_nl: "\n#{newline_indent}"
          )
          json.gsub(/"([^"]+)":/, '\1:')
        end

        def underscore_keys(hash)
          return hash unless hash.is_a?(Hash)

          hash.each_with_object({}) do |(key, value), h|
            h[key.underscore] = underscore_keys(value)
          end
        end
      end
    end
  end
end
