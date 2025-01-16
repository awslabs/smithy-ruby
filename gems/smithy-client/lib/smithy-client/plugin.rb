# frozen_string_literal: true

module Smithy
  module Client
    # Base plugin that all plugins should inherit from.
    #
    # @example
    #    class MyPlugin < Plugin
    #      option :my_option, default: 'default'
    #
    #      def add_handlers(handlers, _config)
    #        handlers.add(Handler)
    #      end
    #
    #      class Handler < Client::Handler
    #        def call(context)
    #          ...
    #        end
    #      end
    #    end
    class Plugin
      extend HandlerBuilder

      # @param [Configuration] config
      # @return [void]
      def add_options(config)
        self.class.options.each do |option|
          if option.default_block
            config.add_option(option.name, &option.default_block)
          else
            config.add_option(option.name, option.default)
          end
        end
      end

      # @param [HandlerList] handlers
      # @param [Configuration] _config
      # @return [void]
      def add_handlers(handlers, _config)
        handlers.copy_from(self.class.handlers)
      end

      # @param [Class<Base>] client_class
      # @param [Hash] options
      # @return [void]
      def before_initialize(client_class, options)
        self.class.before_initialize_hooks.each do |block|
          block.call(client_class, options)
        end
      end

      # @param [Base] client
      # @return [void]
      def after_initialize(client)
        self.class.after_initialize_hooks.each do |block|
          block.call(client)
        end
      end

      class << self
        # (see PluginOption#initialize)
        def option(name, options = {}, &block)
          options[:default_block] = block if block_given?
          self.options << PluginOption.new(name, options)
        end

        def before_initialize(&block)
          before_initialize_hooks << block
        end

        def after_initialize(&block)
          after_initialize_hooks << block
        end

        # @return [Array<PluginOption>]
        def options
          @options ||= []
        end

        # @return [HandlerList]
        def handlers
          @handlers ||= HandlerList.new
        end

        # @return [Array<Proc>]
        def before_initialize_hooks
          @before_initialize_hooks ||= []
        end

        # @return [Array<Proc>]
        def after_initialize_hooks
          @after_initialize_hooks ||= []
        end
      end

      # Holds the configuration for a plugin option.
      class PluginOption
        # @param [Symbol] name
        # @param [Hash] options
        # @option options [Object] :default
        # @option options [Proc] :default_block Can also be set by passing a block.
        # @option options [String] :doc_type
        # @option options [String] :doc_default
        # @option options [String] :docstring
        # @option options [String] :rbs_type
        def initialize(name, options = {})
          @name = name
          # prevent unstable object shapes by ensuring
          # order and presence of instance variables
          @default = nil
          @default_block = nil
          @doc_default = nil
          @doc_type = nil
          @docstring = nil
          @rbs_type = nil
          options.each_pair do |opt_name, opt_value|
            send("#{opt_name}=", opt_value)
          end
        end

        # @return [Symbol]
        attr_reader :name

        # @return [Object, nil]
        attr_accessor :default

        # @return [Proc, nil]
        attr_accessor :default_block

        # @return [String, nil]
        attr_accessor :doc_default

        # @return [String, nil]
        attr_accessor :doc_type

        # @return [String, nil]
        attr_accessor :docstring

        # @return [String, nil]
        attr_accessor :rbs_type
      end
    end
  end
end
