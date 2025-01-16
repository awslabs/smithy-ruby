# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class Client < View
        def initialize(plan)
          @plan = plan
          @model = plan.model
          @plugins = PluginList.new(plan)
          super()
        end

        def namespace
          Util::Namespace.namespace_from_gem_name(@plan.options[:gem_name])
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
