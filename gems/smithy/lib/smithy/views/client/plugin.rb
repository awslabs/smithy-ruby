# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class Plugin
        def initialize(options = {})
          @class_name = options[:class_name]
          @require_path = options[:require_path]
          @require_relative = options.fetch(:require_relative, false)
          @source = options[:source]
        end

        attr_accessor :class_name, :require_path, :source

        def options
          klass = @class_name
          klass = Object.const_get(@class_name) if @class_name.is_a?(String)
          klass.options
        end

        def require_relative?
          @require_relative
        end
      end
    end
  end
end
