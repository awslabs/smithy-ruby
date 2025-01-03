# frozen_string_literal: true

require 'erb'

module Smithy
  module Anvil
    # @api private
    class View
      class << self
        def inherited(subclass)
          parts = (subclass.name || '').split('::')
          parts.shift(2) #=> remove Smithy::Anvil
          type = parts.shift #=> remove Client/Server/Types
          parts.shift #=> remove Views
          parts.unshift(type, 'Templates') #=> add <Type>::Templates
          path = File.join(parts.map(&:underscore))
          subclass.template_file = File.expand_path("#{path}.erb", __dir__)
          super
        end

        attr_accessor :template_file
      end

      def hammer(template_file = nil)
        if template_file && !File.exist?(template_file)
          template_file = File.expand_path(template_file, __dir__)
        end
        ERB.new(File.read(template_file || self.class.template_file), trim_mode: '-').result(binding)
      end
    end
  end
end
