# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class Client < View
        def initialize(plan, code_generated_plugins)
          @plan = plan
          @model = plan.model
          @plugins = PluginList.new(plan, code_generated_plugins)
          super()
        end

        def module_name
          @plan.module_name
        end

        def gem_name
          @plan.gem_name
        end

        def gem_version
          @plan.gem_version
        end

        def require_plugins
          requires = []
          @plugins.each do |plugin|
            next if !@plan.destination_root && plugin.require_relative?

            requires << "require#{'_relative' if plugin.require_relative?} '#{plugin.require_path}'"
          end
          requires
        end

        def add_plugins
          @plugins.map(&:class_name)
        end

        def docstrings
          options = @plugins.map(&:options).flatten.sort_by(&:name)
          documentation = {}
          options.each do |option|
            documentation[option.name] = option_docstrings(option) if option.docstring
          end
          docstrings = []
          documentation.each_value { |value| docstrings.concat(value) }
          docstrings
        end

        def operations
          Model::ServiceIndex
            .new(@model)
            .operations_for(@plan.service)
            .map { |id, operation| Operation.new(@model, id, operation) }
        end

        private

        def option_docstrings(option)
          docstrings = []
          docstrings << option_tag(option)
          documentation = option.docstring.split("\n").map { |line| " #{line}" }
          docstrings.concat(documentation)
          docstrings
        end

        def option_tag(option)
          tag = StringIO.new
          tag << '@option options'
          tag << " [#{option.doc_type}]" if option.doc_type
          tag << " :#{option.name}"
          default = option.doc_default || option.default
          tag << " (#{default})" if default
          tag.string
        end

        # @api private
        class Operation
          def initialize(model, id, operation)
            @model = model
            @id = id
            @operation = operation
          end

          def docstrings
            docstrings = []
            docstrings.concat(OperationExamples.new(@model, name, @operation).docstrings)
            docstrings.concat(RequestResponseExample.new(@model, name, @operation).docstrings)
            docstrings
          end

          def name
            Model::Shape.name(@id).underscore
          end
        end
      end
    end
  end
end
