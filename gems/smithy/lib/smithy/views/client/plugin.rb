# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class Plugin
        def initialize(options = {})
          @class_name = options[:class_name]
          @path = options[:path]
          @relative_path = options.fetch(:relative_path, false)
          @require_path = options[:require_path]
          @require_relative = options.fetch(:require_relative, false)
          @source = options[:source]
        end

        attr_reader :class_name, :path, :require_path, :source

        def docstrings
          docstrings = []
          options.each do |option|
            docstrings.concat(option_docstrings(option)) if option.docstring
          end
          docstrings
        end

        def options
          Object.const_get(@class_name).options
        end

        def relative_path?
          @relative_path
        end

        def require_relative?
          @require_relative
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
      end
    end
  end
end
