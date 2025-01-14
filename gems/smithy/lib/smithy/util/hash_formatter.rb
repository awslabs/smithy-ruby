# frozen_string_literal: true

module Smithy
  module Util
    # A class to format a hash into a string.
    class HashFormatter
      # @option options [Boolean] :wrap (true) When `true`, the formatted hash will
      #   be wrapped with curly braces.
      # @option options [Boolean] :inline (false) When `true` the formatted hash will
      #   contain no newlines.
      # @option options [Boolean] :quote_strings (false) By default, all hash string values
      #   must contain their own quotes. If you pass `true`, then all hash string
      #   values will be inspected via `#inspect` which will auto-quote them.
      # @option options [String] :indent ('') The indentation to use for the hash.
      def initialize(options = {})
        @wrap = options.fetch(:wrap, true)
        @inline = options.fetch(:inline, false)
        @quote_strings = options.fetch(:quote_strings, false)
        @indent = options.fetch(:indent, '')
      end

      # @return [String]
      def format(obj)
        result = hash(obj, indent: @indent, inline: @inline)
        result = unwrap(result, obj.size) unless @wrap
        result = result.strip if @inline && result.lines.to_a.length == 1
        result
      end

      private

      def value(obj, options)
        indent = options.fetch(:indent)
        inline = options.fetch(:inline)
        case obj
        when Hash then hash(obj, indent: indent, inline: inline)
        when Array then array(obj, indent: indent)
        when String then @quote_strings ? obj.inspect : obj
        when Symbol, Numeric, true, false then obj.inspect
        else raise ArgumentError, "unsupported value: #{obj.class}"
        end
      end

      def hash(hash, options)
        indent = options.fetch(:indent)
        inline = options.fetch(:inline)
        if hash.empty?
          '{}'
        elsif inline_hash?(hash, inline)
          inline_hash(hash)
        else
          multiline_hash(hash, indent: indent)
        end
      end

      def inline_hash(hash)
        "{ #{hash_entry(hash.keys[0], hash.values[0], indent: '')} }"
      end

      def multiline_hash(hash, options)
        indent = options.fetch(:indent)
        str = "{\n"
        hash.each.with_index do |(key, value), n|
          str += "#{indent}  #{hash_entry(key, value, indent: indent)}"
          str += ',' unless n == hash.keys.length - 1
          str += "\n"
        end
        str + "#{indent}}"
      end

      def hash_entry(key, value, options)
        indent = options.fetch(:indent)
        value = value(value, indent: "#{indent}  ", inline: false)
        if key.is_a?(Symbol)
          "#{key}: #{value}"
        else
          "#{key.inspect} => #{value}"
        end
      end

      def array(array, options)
        indent = options.fetch(:indent)
        if array.empty?
          '[]'
        elsif inline_array?(array)
          "[#{value(array[0], indent: indent, inline: true)}]"
        else
          format_multiline_array(array, indent: indent)
        end
      end

      def format_multiline_array(array, options)
        indent = options.fetch(:indent)
        str = "[\n"
        array.each.with_index do |value, n|
          str += "#{indent}  #{value(value, indent: "#{indent}  ", inline: true)}"
          str += ',' unless n == array.length - 1
          str += "\n"
        end
        str + "#{indent}]"
      end

      def inline_hash?(hash, inline)
        hash.length == 1 && hash.values[0].is_a?(String) && inline
      end

      def inline_array?(array)
        array.length == 1
      end

      def unwrap(str, size)
        if @inline || size > 1
          str[1..-2]
        else
          lines = str.lines.to_a
          lines.shift
          lines.pop
          lines = lines.map { |line| line[2..] }
          lines.join.rstrip
        end
      end
    end
  end
end
