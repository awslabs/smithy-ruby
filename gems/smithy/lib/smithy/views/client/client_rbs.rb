# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class ClientRbs < View
        def initialize(plan, code_generated_plugins)
          @plan = plan
          @model = plan.model
          @plugins = plugins(plan, code_generated_plugins)

          super()
        end

        def module_name
          @plan.module_name
        end

        def option_types
          # TODO: Ensure this order is correct when plugins override options
          @plugins
            .map(&:options)
            .flatten
            .select(&:docstring) # include only documented options
            .sort_by(&:name)
            .to_h { |o| [o.name, rbs_type(o)] }
        end

        def operations
          @operations = Model::ServiceIndex
                        .new(@model)
                        .operations_for(@plan.service)
                        .map { |id, operation| Operation.new(@model, id, operation) }
        end

        private

        def plugins(plan, code_generated_plugins)
          define_module_names
          code_generated_plugins.each do |plugin|
            Object.module_eval(plugin.source)
          end
          PluginList.new(plan).to_a + code_generated_plugins.to_a
        end

        def define_module_names
          parent = Object
          module_name.split('::') do |mod|
            child = mod
            parent.const_set(child, ::Module.new) unless parent.const_defined?(child)
            parent = parent.const_get(child)
          end
        end

        def rbs_type(option)
          return option.rbs_type if option.rbs_type

          return doc_to_rbs_types(option.doc_type) if option.doc_type

          'untyped'
        end

        # doc types may specify multiple types combined with ","
        def doc_to_rbs_types(doc_type)
          doc_type
            .to_s
            .split(',')
            .map(&:strip)
            .map { |t| doc_to_rbs_type(t) }
            .join(' | ')
        end

        def doc_to_rbs_type(doc_type)
          case doc_type
          when 'Boolean' then 'bool'
          else
            doc_type
          end
        end

        # @api private
        class Operation
          def initialize(model, id, operation)
            @model = model
            @id = id
            @operation = operation
            @input = Input.new(model, operation['input']['target'])
            @output = Output.new(model, operation['output']['target'])
          end

          attr_reader :input, :output

          def response_interface
            "_#{Model::Shape.name(@id)}Response"
          end

          def name
            Model::Shape.name(@id).underscore
          end
        end

        # @api private
        class Output
          def initialize(model, id)
            @model = model
            @id = id
            @shape = Model.shape(model, id)
          end

          def type
            Model::RBS.type(@model, @id, @shape)
          end

          def member_types
            @shape.fetch('members', {}).to_h do |member_name, member|
              target = Model.shape(@model, member['target'])
              [member_name.underscore, Model::RBS.type(@model, member['target'], target)]
            end
          end
        end

        # @api private
        class Input
          def initialize(model, id)
            @model = model
            @id = id
            @shape = Model.shape(model, id)
          end

          def members?
            @shape.fetch('members', {}).any?
          end

          # @return [Array<String>]
          def keyword_args
            lines = []
            @shape.fetch('members', {}).each do |name, member|
              member_lines = kwargs_structure_member(name, member['target'])
              # top level members all need to be considered optional
              member_lines[0] = "?#{member_lines[0].strip}"
              lines += member_lines
            end
            lines.last&.chomp!(',')
            lines
          end

          private

          def kwargs_structure_member(name, id, level = 0, visited = Set.new)
            return indent(["#{name.underscore}: untyped,"], level) if visited.include?(id)

            visited << id
            shape = Model.shape(@model, id)
            if complex?(shape)
              kwargs_complex_structure_member(level, name, shape, visited)
            else
              indent(["#{name.underscore}: #{Model::RBS.type(@model, nil, shape)},"], level)
            end
          end

          def kwargs_complex_structure_member(level, name, shape, visited)
            lines = kwargs_complex_shape(shape, level, visited)
            lines[0] = indent("#{name.underscore}: #{lines[0].strip}", level)
            lines[lines.size - 1] = "#{lines.last},"
            lines
          end

          def kwargs_complex_shape(shape, level, visited)
            case shape['type']
            when 'list'
              kwargs_list(shape, level, visited)
            when 'map'
              kwargs_map(shape, level, visited)
            when 'structure', 'union'
              kwargs_structure(shape, level, visited)
            else
              ['untyped']
            end
          end

          def kwargs_structure(shape, level, visited)
            lines = [indent('{', level)]
            shape.fetch('members', {}).each do |name, member|
              lines += kwargs_structure_member(name, member['target'], level + 1, visited)
            end
            lines[lines.size - 1] = lines.last.chomp(',')
            lines << indent('}', level)
            lines
          end

          def kwargs_list(shape, level, visited)
            member_target = Model.shape(@model, shape['member']['target'])
            if complex?(member_target)
              lines = [indent('Array[', level)]
              lines += kwargs_complex_shape(member_target, level + 1, visited)
              lines << indent(']', level)
              lines
            else
              sparse = shape.fetch('traits', {}).key?('smithy.api#sparse')
              indent(
                ["Array[#{Model::RBS.type(@model, shape['member']['target'], member_target)}#{'?' if sparse}]"],
                level
              )
            end
          end

          def kwargs_map(shape, level, visited)
            key_target = Model.shape(@model, shape['key']['target'])
            key_type = Model::RBS.type(@model, shape['key']['target'], key_target)
            value_target = Model.shape(@model, shape['value']['target'])
            if complex?(value_target)
              kwargs_complex__map(key_type, level, value_target, visited)
            else
              kwargs_simple_map(key_type, level, shape, value_target)
            end
          end

          def kwargs_simple_map(key_type, level, shape, value_target)
            sparse = shape.fetch('traits', {}).key?('smithy.api#sparse')
            value_type = Model::RBS.type(@model, shape['value']['target'], value_target)
            indent(
              ["Hash[#{key_type}, #{value_type}#{'?' if sparse}]"],
              level
            )
          end

          def kwargs_complex__map(key_type, level, value_target, visited)
            lines = [indent("Hash[#{key_type},", level)]
            lines += kwargs_complex_shape(value_target, level + 1, visited)
            lines << indent(']', level)
            lines
          end

          def complex?(shape)
            %w[list map structure union].include?(shape['type'])
          end

          def indent(str, level)
            case str
            when Array then str.map { |s| indent(s, level) }
            else
              ('  ' * level) + str
            end
          end
        end
      end
    end
  end
end
