# frozen_string_literal: true

module Smithy
  module Util
    # @api private
    module Namespace
      # @return [String] Returns the namespace for the given gem name.
      def self.namespace_from_gem_name(gem_name)
        namespaces_from_gem_name(gem_name).join('::')
      end

      # @return [Array<String>] Returns the namespaces for the given gem name.
      def self.namespaces_from_gem_name(gem_name)
        gem_name.split('-').map do |part|
          part.split('_').map(&:capitalize).join
        end
      end

      # @return [String] Returns the gem name for the given namespace.
      def self.gem_name_from_namespace(namespace)
        gem_name_from_namespaces(namespace.split('::'))
      end

      # @return [String] Returns the gem name for the given namespaces.
      def self.gem_name_from_namespaces(namespaces)
        namespaces.map do |part|
          part.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
        end.join('-')
      end
    end
  end
end
