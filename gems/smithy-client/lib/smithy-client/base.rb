# frozen_string_literal: true

module Smithy
  module Client
    # Base class for all service clients.
    class Base
      include HandlerBuilder

      # @api private
      @plugins = PluginList.new(
        [
          # Plugins::NetHTTP
          Plugins::RaiseResponseErrors
          # Plugins::ResponseTarget,
          # Plugins::RequestCallback
        ]
      )

      # @api private
      def initialize(plugins, options)
        @config = build_config(plugins, options)
        @handlers = build_handler_list(plugins)
        after_initialize(plugins)
      end

      # @return [Configuration<Struct>]
      attr_reader :config

      # @return [HandlerList]
      attr_reader :handlers

      # Builds and returns an {Input} for the named operation. The request
      #  will not have been sent.
      # @param [Symbol] operation_name
      # @return [Input]
      def build_input(operation_name, params = {})
        Input.new(
          handlers: @handlers.for(operation_name),
          context: context_for(operation_name, params)
        )
      end

      # @return [Array<Symbol>] Returns a list of valid request operation
      #  names. These are valid arguments to {#build_input} and are also
      #  valid methods.
      def operation_names
        self.class.api.operation_names
      end

      # @api private
      def inspect
        "#<#{self.class.name || 'Smithy::Client::Base'}>"
      end

      private

      # Constructs a {Configuration} object and gives each plugin the
      #  opportunity to register options with default values.
      def build_config(plugins, options)
        config = Configuration.new
        config.add_option(:api)
        config.add_option(:plugins)
        plugins.each do |plugin|
          plugin.add_options(config) if plugin.respond_to?(:add_options)
        end
        config.build!(options.merge(api: self.class.api))
      end

      # Gives each plugin the opportunity to register handlers for this client.
      def build_handler_list(plugins)
        plugins.each_with_object(HandlerList.new) do |plugin, handlers|
          plugin.add_handlers(handlers, @config) if plugin.respond_to?(:add_handlers)
        end
      end

      # Gives each plugin the opportunity to modify this client.
      def after_initialize(plugins)
        plugins.reverse.each do |plugin|
          plugin.after_initialize(self) if plugin.respond_to?(:after_initialize)
        end
      end

      # @return [HandlerContext]
      def context_for(operation_name, params)
        HandlerContext.new(
          operation_name: operation_name,
          operation: config.api.operation(operation_name),
          client: self,
          params: params,
          config: config
        )
      end

      class << self
        def new(options = {})
          options = options.dup
          options[:plugins]&.freeze
          plugins = build_plugins(self.plugins + options.fetch(:plugins, []))
          plugins = before_initialize(plugins, options)
          client = allocate
          client.send(:initialize, plugins, options)
          client
        end

        # Registers a plugin with this client.
        #
        # @example Register a plugin
        #
        #   ClientClass.add_plugin(PluginClass)
        #
        # @example Register a plugin with an object
        #
        #   plugin = MyPluginClass.new(options)
        #   ClientClass.add_plugin(plugin)
        #
        # @param [Class, Symbol, String, Object] plugin
        # @see .clear_plugins
        # @see .set_plugins
        # @see .remove_plugin
        # @see .plugins
        # @return [void]
        def add_plugin(plugin)
          @plugins.add(plugin)
        end

        # @see .clear_plugins
        # @see .set_plugins
        # @see .add_plugin
        # @see .plugins
        # @return [void]
        def remove_plugin(plugin)
          @plugins.remove(plugin)
        end

        # @see .set_plugins
        # @see .add_plugin
        # @see .remove_plugin
        # @see .plugins
        # @return [void]
        def clear_plugins
          @plugins.set([])
        end

        # @param [Array<Plugin>] plugins
        # @see .clear_plugins
        # @see .add_plugin
        # @see .remove_plugin
        # @see .plugins
        # @return [void]
        def plugins=(plugins)
          @plugins.set(plugins)
        end

        # Returns the list of registered plugins for this Client. Plugins are
        #  inherited from the client super class when the client is defined.
        # @see .clear_plugins
        # @see .set_plugins
        # @see .add_plugin
        # @see .remove_plugin
        # @return [Array<Plugin>]
        def plugins
          Array(@plugins).freeze
        end

        # @return [API]
        def api
          @api ||= API.new
        end

        # @param [API] api
        def api=(api)
          @api = api
          define_operation_methods
        end

        # @option options [API] :api (API.new)
        # @option options [Array<Plugin>] :plugins ([]) A list of plugins to
        #  add to the client class created.
        # @return [Class<Client::Base>]
        def define(options = {})
          subclass = Class.new(self)
          subclass.api = options[:api] || api
          Array(options[:plugins]).each do |plugin|
            subclass.add_plugin(plugin)
          end
          subclass
        end
        alias extend define

        private

        def define_operation_methods
          operations_module = Module.new
          @api.operation_names.each do |method_name|
            operations_module.send(:define_method, method_name) do |*args, &block|
              params = args[0] || {}
              options = args[1] || {}
              build_input(method_name, params).send_request(options, &block)
            end
          end
          include(operations_module)
        end

        def build_plugins(plugins)
          plugins.map { |plugin| plugin.is_a?(Class) ? plugin.new : plugin }
        end

        def before_initialize(plugins, options)
          plugins.each do |plugin|
            plugin.before_initialize(self, options) if plugin.respond_to?(:before_initialize)
          end
        end

        def inherited(subclass)
          super
          subclass.instance_variable_set('@plugins', PluginList.new(@plugins))
        end
      end
    end
  end
end
