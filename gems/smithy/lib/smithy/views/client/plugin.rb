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

        def options
          Object.const_get(@class_name).options
        end

        def relative_path?
          @relative_path
        end

        def require_relative?
          @require_relative
        end
      end
    end
  end
end
