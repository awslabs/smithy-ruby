# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class PluginList
        include Enumerable

        def initialize(plan)
          @plan = plan
          @plugins = default_plugins + transport_plugins('http') + generated_plugins
          @plugins.each do |plugin|
            require_path = plugin.require_path
            next unless require_path

            require_path = File.absolute_path(require_path) unless plugin.relative_path?
            Kernel.require(require_path)
          end
        end

        def each(&)
          @plugins.each(&)
        end

        private

        def namespace
          Util::Namespace.namespace_from_gem_name(@plan.options[:gem_name])
        end

        def gem_name
          @plan.options[:gem_name]
        end

        def gem_dir
          @plan.options[:destination_root]
        end

        def default_plugins
          Smithy::Client::Base.plugins.map do |plugin|
            Plugin.new(class_name: plugin.name, require_path: nil, default: true)
          end
        end

        # def weld_plugins
        #   plugins = @plan.welds.map(&:plugins).reduce({}, :merge)
        #   plugins.map do |class_name, path|
        #     Plugin.new(class_name: class_name, path: path)
        #   end
        # end

        def generated_plugins
          # Nested namespaces for Plugins will not load unless we define them.
          define_namespaces
          plugins = {
            "#{namespace}::Plugins::Endpoint" => "#{gem_dir}/lib/#{gem_name}/plugins/endpoint.rb"
          }
          plugins.map do |class_name, require_path|
            Plugin.new(class_name: class_name, require_path: require_path)
          end
        end

        def transport_plugins(protocol)
          plugins = {
            'http' => { 'Smithy::Client::Plugins::NetHTTP' => 'smithy-client/plugins/net_http' }
          }[protocol]
          plugins.map do |class_name, require_path|
            Plugin.new(class_name: class_name, require_path: require_path, relative_path: true, requirable: true)
          end
        end

        def define_namespaces
          parent = Object
          namespace.split('::') do |mod|
            child = mod
            parent.const_set(child, ::Module.new) unless parent.const_defined?(child)
            parent = parent.const_get(child)
          end
        end
      end
    end
  end
end
