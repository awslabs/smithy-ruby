# frozen_string_literal: true

require 'bigdecimal'
require 'stringio'
require 'date'
require 'time'
require 'tempfile'

module Smithy
  module Client
    # @api private
    class ParamConverter
      include Smithy::Client::Shapes

      @mutex = Mutex.new
      @converters = Hash.new { |h, k| h[k] = {} }

      def initialize(rules)
        @rules = rules
        @opened_files = []
      end

      attr_reader :opened_files

      # @param [Hash] params
      # @return [Hash]
      def convert(params)
        structure(@rules, params)
      end

      def close_opened_files
        @opened_files.each(&:close)
        @opened_files = []
      end

      private

      def structure(ref, values)
        values = c(ref, values)
        if values.is_a?(::Struct) || values.is_a?(Hash)
          values.each_pair do |k, v|
            next if v.nil?
            next unless ref.member?(k)

            values[k] = member(ref.member(k), v)
          end
        end
        values
      end

      def list(ref, values)
        values = c(ref, values)
        if values.is_a?(Array)
          values.map { |v| member(ref.member, v) }
        else
          values
        end
      end

      def map(ref, values)
        values = c(ref, values)
        if values.is_a?(Hash)
          values.each.with_object({}) do |(key, value), hash|
            hash[member(ref.key, key)] = member(ref.value, value)
          end
        else
          values
        end
      end

      def member(ref, value)
        case ref.shape
        when StructureShape then structure(ref.shape, value)
        when ListShape then list(ref.shape, value)
        when MapShape then map(ref.shape, value)
        else c(ref.shape, value)
        end
      end

      def c(ref, value)
        self.class.c(ref.class, value, self)
      end

      class << self
        def convert(shape, params)
          new(shape).convert(params)
        end

        # Registers a new value converter. Converters run in the context
        # of a shape and value class.
        #
        #     # add a converter that stringifies integers
        #     shape_class = Shapes::StringShape
        #     ParamConverter.add(shape_class, Integer) { |i| i.to_s }
        #
        # @param [Class<Shapes::Shape>] shape_class
        # @param [Class] value_class
        # @param [#call] block An object that responds to `#call`
        #    accepting a single argument. This function should perform
        #    the value conversion if possible, returning the result.
        #    If the conversion is not possible, the original value should
        #    be returned.
        # @return [void]
        def add(shape_class, value_class, &block)
          @converters[shape_class][value_class] = block
        end

        def ensure_open(file, converter)
          if file.closed?
            new_file = File.open(file.path, 'rb')
            converter.opened_files << new_file
            new_file
          else
            file
          end
        end

        def c(shape, value, instance = nil)
          if (converter = converter_for(shape, value))
            converter.call(value, instance)
          else
            value
          end
        end

        private

        def converter_for(shape_class, value)
          unless @converters[shape_class].key?(value.class)
            @mutex.synchronize do
              unless @converters[shape_class].key?(value.class)
                @converters[shape_class][value.class] = find(shape_class, value)
              end
            end
          end
          @converters[shape_class][value.class]
        end

        def find(shape_class, value)
          converter = nil
          each_base_class(shape_class) do |klass|
            @converters[klass].each do |value_class, block|
              if value.is_a?(value_class)
                converter = block
                break
              end
            end
            break if converter
          end
          converter
        end

        def each_base_class(shape_class, &block)
          shape_class.ancestors.each do |ancestor|
            yield(ancestor) if @converters.key?(ancestor)
          end
        end
      end

      add(BigDecimalShape, BigDecimal)
      add(BigDecimalShape, Integer) { |i| BigDecimal(i) }
      add(BigDecimalShape, Float) { |f| BigDecimal(f.to_s) }
      add(BigDecimalShape, String) do |str|
        BigDecimal(str)
      rescue ArgumentError
        str
      end

      add(BlobShape, IO)
      add(BlobShape, File) { |file, converter| ensure_open(file, converter) }
      add(BlobShape, Tempfile) { |tmpfile, converter| ensure_open(tmpfile, converter) }
      add(BlobShape, StringIO)
      add(BlobShape, String)

      add(BooleanShape, TrueClass)
      add(BooleanShape, FalseClass)
      add(BooleanShape, String) do |str|
        { 'true' => true, 'false' => false }[str]
      end

      add(EnumShape, String)
      add(EnumShape, Symbol) { |sym| sym.to_s }

      add(IntegerShape, Integer)
      add(IntegerShape, Float) { |f| f.to_i }
      add(IntegerShape, String) do |str|
        Integer(str)
      rescue ArgumentError
        str
      end

      add(IntEnumShape, Integer)
      add(IntEnumShape, Float) { |f| f.to_i }
      add(IntEnumShape, String) do |str|
        Integer(str)
      rescue ArgumentError
        str
      end

      add(FloatShape, Float)
      add(FloatShape, Integer) { |i| i.to_f }
      add(FloatShape, String) do |str|
        Float(str)
      rescue ArgumentError
        str
      end

      add(ListShape, Array) { |a| a.dup }
      add(ListShape, Enumerable) { |value| value.to_a }

      add(MapShape, Hash) { |h| h.dup }
      add(MapShape, ::Struct) do |s|
        s.members.each.with_object({}) { |k, h| h[k] = s[k] }
      end

      add(StringShape, String)
      add(StringShape, Symbol) { |sym| sym.to_s }

      add(StructureShape, Hash) { |h| h.dup }
      add(StructureShape, ::Struct)

      add(TimestampShape, Time)
      add(TimestampShape, Date) { |d| d.to_time }
      add(TimestampShape, DateTime) { |dt| dt.to_time }
      add(TimestampShape, Integer) { |i| Time.at(i) }
      add(TimestampShape, Float) { |f| Time.at(f) }
      add(TimestampShape, String) do |str|
        Time.parse(str)
      rescue ArgumentError
        str
      end

      # TODO: union shape
    end
  end
end
