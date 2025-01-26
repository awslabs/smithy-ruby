# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class Plugin
        def initialize(options = {})
          @class_name = options[:class_name]
          @path = options[:path]
          @source = options[:source]
          @default = options.fetch(:default, false)
          @relative_path = options.fetch(:relative_path, false)
          @requirable = options.fetch(:requirable, false)
        end

        attr_reader :class_name, :path, :source

        def docstrings
          docstrings = []
          options = Object.const_get(@class_name).options
          options.each do |option|
            docstrings.concat(option_docstrings(option)) if option.docstring
          end
          docstrings
        end

        def default?
          @default
        end

        def relative_path?
          @relative_path
        end

        def requirable?
          @requirable
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
