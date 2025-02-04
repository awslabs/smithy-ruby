# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class Client < View
        def initialize(plan, code_generated_plugins)
          @plan = plan
          @model = plan.model
          @plugins = plugins(plan, code_generated_plugins)
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
          @plugins.map do |plugin|
            "require#{'_relative' if plugin.require_relative?} '#{plugin.require_path}'"
          end
        end

        def add_plugins
          @plugins.map(&:class_name)
        end

        def docstrings
          docstrings = []
          @plugins.options_docstrings.each_value do |value|
            docstrings.concat(value)
          end
          docstrings
        end

        def operations
          Model::ServiceIndex
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
          PluginList.new(plan, code_generated_plugins)
        end

        def define_module_names
          parent = Object
          module_name.split('::') do |mod|
            child = mod
            parent.const_set(child, ::Module.new) unless parent.const_defined?(child)
            parent = parent.const_get(child)
          end
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
