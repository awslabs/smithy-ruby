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

        def namespace
          @plan.gem_namespace
        end

        def gem_name
          @plan.options[:gem_name]
        end

        def gem_version
          @plan.options[:gem_version]
        end

        def require_plugins
          @plugins.select(&:requirable?).map(&:require_path)
        end

        def add_plugins
          @plugins.reject(&:default?).map(&:class_name)
        end

        def docstrings
          docstrings = []
          docstrings << '@param [Hash] options'
          # TODO: ensure correct handling of duplicate option definitions
          @plugins.each do |plugin|
            docstrings.concat(plugin.docstrings)
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
          define_namespaces
          code_generated_plugins.each do |plugin|
            Object.module_eval(plugin.source)
          end
          PluginList.new(plan).to_a + code_generated_plugins.to_a
        end

        def define_namespaces
          parent = Object
          namespace.split('::') do |mod|
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
