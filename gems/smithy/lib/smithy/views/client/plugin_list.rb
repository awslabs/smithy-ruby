# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class PluginList
        include Enumerable

        def initialize(plan)
          @plan = plan
          @module_name = plan.module_name
          @gem_name = plan.gem_name
          @gem_version = plan.gem_version
          @plugins = default_plugins + transport_plugins('http')
          @plugins.each do |plugin|
            require_path = plugin.require_path
            next unless require_path

            require_path = File.absolute_path(require_path) unless plugin.relative_path?
            Kernel.require(require_path)
          end
        end

        attr_reader :module_name, :gem_name, :gem_version

        def each(&)
          @plugins.each(&)
        end

        private

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

        def transport_plugins(protocol)
          plugins = {
            'http' => { 'Smithy::Client::Plugins::NetHTTP' => 'smithy-client/plugins/net_http' }
          }[protocol]
          plugins.map do |class_name, require_path|
            Plugin.new(class_name: class_name, require_path: require_path, relative_path: true, requirable: true)
          end
        end
      end
    end
  end
end
