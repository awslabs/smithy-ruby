# frozen_string_literal: true

module Smithy
  module Client
    module HTTP
      # Provides a Hash-like interface for HTTP headers.  Header names
      # are treated indifferently as lower-cased strings.  Header values
      # are cast to strings.
      #
      #     headers = HTTP::Headers.new
      #     headers['Content-Length'] = 100
      #     headers[:Authorization] = 'Abc'
      #
      #     headers.keys
      #     #=> ['content-length', 'authorization']
      #
      #     headers.values
      #     #=> ['100', 'Abc']
      #
      # You can get the header values as a vanilla hash by calling {#to_h}:
      #
      #     headers.to_h
      #     #=> { 'content-length' => '100', 'authorization' => 'Abc' }
      #
      class Headers
        include Enumerable

        # @api private
        def initialize(headers = {})
          @data = {}
          headers.each_pair do |key, value|
            self[key] = value
          end
        end

        # @yield [key, value]
        # @yieldparam [String] key
        # @yieldparam [String] value
        # @return [nil]
        def each(&block)
          if block_given?
            @data.each_pair(&block)
            nil
          else
            @data.enum_for(:each)
          end
        end
        alias each_pair each

        # @param [String] key
        # @return [String]
        def [](key)
          @data[key.to_s.downcase]
        end

        # @param [String] key
        # @param [String] value
        def []=(key, value)
          @data[key.to_s.downcase] = value.to_s
        end

        # @param [Hash] headers
        # @return [Headers]
        def update(headers)
          headers.each_pair do |k, v|
            self[k] = v
          end
          self
        end

        # @param [String] key
        def delete(key)
          @data.delete(key.to_s.downcase)
        end

        # @return [Headers]
        def clear
          @data = {}
          self
        end

        # @return [Boolean]
        def empty?
          @data.empty?
        end

        # @return [Array<String>]
        def keys
          @data.keys
        end

        # @return [Array<String>]
        def values
          @data.values
        end

        # @return [Array<String>]
        def values_at(*keys)
          @data.values_at(*keys.map { |key| key.to_s.downcase })
        end

        # @return [Boolean] Returns `true` if the header is set.
        def key?(key)
          @data.key?(key.to_s.downcase)
        end
        alias has_key? key?
        alias include? key?

        # @return [Hash]
        def to_hash
          @data.dup
        end
        alias to_h to_hash

        # @api private
        def inspect
          @data.inspect
        end
      end
    end
  end
end
