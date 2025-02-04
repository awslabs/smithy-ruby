# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class PluginList
        include Enumerable

        def initialize(plan, code_generated_plugins)
          @plan = plan
          @plugins = plugins(plan.welds, code_generated_plugins)
          @plugins.each do |plugin|
            next if plugin.source

            path = plugin.path
            next unless path

            path = File.absolute_path(path) unless plugin.relative_path?
            Kernel.require(path)
          end
        end

        def each(&)
          @plugins.each(&)
        end

        def options_docstrings
          options = @plugins.map(&:options).flatten.sort_by(&:name)
          docstrings = {}
          options.each do |option|
            docstrings[option.name] = option_docstrings(option) if option.docstring
          end
          docstrings
        end

        private

        def plugins(welds, code_generated_plugins)
          plugins = []
          code_generated_plugins.map { |plugin| plugins << plugin }
          weld_plugins = welds.map(&:plugins).reduce({}, :merge)
          weld_plugins.map do |class_name, options|
            plugins << Plugin.new(class_name: class_name, **options)
          end
          plugins
        end

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
      end
    end
  end
end
