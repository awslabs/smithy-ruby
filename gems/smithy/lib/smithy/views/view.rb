# frozen_string_literal: true

require 'erb'

module Smithy
  module Views
    # @api private
    class View
      class << self
        TEMPLATE_DIR = File.expand_path('../templates', __dir__.to_s)

        def inherited(subclass)
          parts = (subclass.name || '').split('::')
          parts.shift(2) #=> remove Smithy::Views
          type = parts.shift #=> remove Client/Server
          parts.unshift(type) #=> add <Type>
          path = File.join(parts.map(&:underscore))
          subclass.template_file = File.join(TEMPLATE_DIR, "#{path}.erb")
          super
        end

        attr_accessor :template_file
      end

      def namespace
        @plan.options[:gem_namespace] || Util::Namespace.namespace_from_gem_name(@plan.options[:gem_name])
      end

      def render
        ERB.new(File.read(self.class.template_file), trim_mode: '-').result(binding)
      end
    end
  end
end
