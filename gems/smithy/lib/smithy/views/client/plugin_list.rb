# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class PluginList
        include Enumerable

        def initialize(plan, code_generated_plugins)
          @plan = plan
          @plugins = plugins(plan, code_generated_plugins)
        end

        def each(&)
          @plugins.each(&)
        end

        private

        def plugins(plan, code_generated_plugins)
          plugins = []
          code_generated_plugins(plugins, code_generated_plugins)
          weld_plugins(plugins, plan.welds)
          plugins
        end

        def code_generated_plugins(plugins, code_generated_plugins)
          define_module_names
          code_generated_plugins.each do |_, plugin| # rubocop:disable Style/HashEachMethods
            Object.module_eval(plugin.source)
            plugins << plugin
          end
        end

        # Code generated plugins may have nested namespaces, so we need to ensure
        # that they are defined before we try to evaluate the source.
        def define_module_names
          parent = Object
          @plan.module_name.split('::') do |mod|
            child = mod
            parent.const_set(child, ::Module.new) unless parent.const_defined?(child)
            parent = parent.const_get(child)
          end
        end

        def weld_plugins(plugins, welds)
          weld_plugins = welds.map(&:plugins).reduce({}, :merge)
          weld_plugins.each do |class_name, options|
            plugins << Plugin.new(class_name: class_name, **options)
          end
        end
      end
    end
  end
end
