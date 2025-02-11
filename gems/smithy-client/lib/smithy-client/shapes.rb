# frozen_string_literal: true

module Smithy
  module Client
    # Represents shape types from the Smithy Model.
    module Shapes
      # A base shape that all shapes inherits from.
      class Shape
        def initialize(options = {})
          @id = options[:id]
          @traits = options[:traits] || {}
        end

        # @return [String, nil]
        attr_accessor :id

        # @return [Hash<String, Object>]
        attr_accessor :traits
      end

      # Represents a slim variation of the Service shape.
      class ServiceShape < Shape
        def initialize(options = {})
          super
          @name = options[:name]
          @version = options[:version]
        end

        # @return [String, nil]
        attr_accessor :version

        # @return [String, nil]
        attr_accessor :name
      end

      # Represents an Operation shape.
      class OperationShape < Shape
        def initialize(options = {})
          super
          @name = options[:name]
          @input = options[:input]
          @output = options[:output]
          @errors = options[:errors] || []
          yield self if block_given?
        end

        # @return [String, nil]
        attr_accessor :name

        # @return [StructureShape, nil]
        attr_accessor :input

        # @return [StructureShape, nil]
        attr_accessor :output

        # @return [Array<StructureShape>]
        attr_accessor :errors
      end

      # Represents a BigDecimal shape.
      class BigDecimalShape < Shape; end

      # Represents both Blob and Data Stream shapes.
      class BlobShape < Shape; end

      # Represents a Boolean shape.
      class BooleanShape < Shape; end

      # Represents a Document shape.
      class DocumentShape < Shape; end

      # Represents an Enum shape.
      class EnumShape < Shape
        def initialize(options = {})
          super
          @members = {}
        end

        # @return [Hash<Symbol, MemberShape>]
        attr_accessor :members

        # @return [MemberShape]
        def add_member(name, shape, traits: {})
          @members[name] = MemberShape.new(shape, traits: traits)
        end

        # @return [Boolean]
        def member?(name)
          @members.key?(name)
        end

        # @return [MemberShape, nil]
        def member(name)
          @members[name]
        end
      end

      # Represents the following shapes: Byte, Short, Integer, Long, BigInteger.
      class IntegerShape < Shape; end

      # Represents an IntEnum shape.
      class IntEnumShape < Shape
        def initialize(options = {})
          super
          @members = {}
        end

        # @return [Hash<Symbol, MemberShape>]
        attr_accessor :members

        # @return [MemberShape]
        def add_member(name, shape, traits: {})
          @members[name] = MemberShape.new(shape, traits: traits)
        end

        # @return [Boolean]
        def member?(name)
          @members.key?(name)
        end

        # @return [MemberShape, nil]
        def member(name)
          @members[name]
        end
      end

      # Represents both Float and Double shapes.
      class FloatShape < Shape; end

      # Represents a List shape.
      class ListShape < Shape
        def initialize(options = {})
          super
          @member = nil
        end

        # @return [MemberShape, nil]
        attr_accessor :member

        # @return [MemberShape]
        def set_member(shape, traits: {})
          @member = MemberShape.new(shape, traits: traits)
        end
      end

      # Represents a Map shape.
      class MapShape < Shape
        def initialize(options = {})
          super
          @key = nil
          @value = nil
        end

        # @return [MemberShape, nil]
        attr_accessor :key

        # @return [MemberShape, nil]
        attr_accessor :value

        # @return [MemberShape]
        def set_key(shape, traits: {})
          @key = MemberShape.new(shape, traits: traits)
        end

        # @return [MemberShape]
        def set_value(shape, traits: {})
          @value = MemberShape.new(shape, traits: traits)
        end
      end

      # Represents a String shape.
      class StringShape < Shape; end

      # Represents a Structure shape.
      class StructureShape < Shape
        def initialize(options = {})
          super
          @members = {}
          @type = nil
        end

        # @return [Hash<Symbol, MemberShape>]
        attr_accessor :members

        # @return [Class]
        attr_accessor :type

        # @return [MemberShape]
        def add_member(name, shape, traits: {})
          @members[name] = MemberShape.new(shape, traits: traits)
        end

        # @return [Boolean]
        def member?(name)
          @members.key?(name)
        end

        # @return [MemberShape, nil]
        def member(name)
          @members[name]
        end
      end

      # Represents a Timestamp shape.
      class TimestampShape < Shape; end

      # Represents both Union and EventStream shapes.
      class UnionShape < Shape
        def initialize(options = {})
          super
          @members = {}
          @type = nil
          @member_types = {}
        end

        # @return [Hash<Symbol, MemberShape>]
        attr_accessor :members

        # @return [Class]
        attr_accessor :type

        # @return [Symbol, Class]
        attr_accessor :member_types

        # @return [MemberShape]
        def add_member(name, shape, type, traits: {})
          @member_types[name] = type
          @members[name] = MemberShape.new(shape, traits: traits)
        end

        # @return [Boolean]
        def member?(name)
          @members.key?(name)
        end

        # @return [MemberShape, nil]
        def member(name)
          @members[name]
        end

        # @return [Class, nil]
        def member_type(name)
          @member_types[name]
        end
      end

      # Represents a member shape.
      class MemberShape
        def initialize(shape, traits: {})
          @shape = shape
          @traits = traits
        end

        # @return [Shape]
        attr_accessor :shape

        # @return [Hash<String, Object>]
        attr_accessor :traits
      end

      # Prelude shape definitions.
      module Prelude
        BigDecimal = BigDecimalShape.new(id: 'smithy.api#BigDecimal')
        BigInteger = IntegerShape.new(id: 'smithy.api#BigInteger')
        Blob = BlobShape.new(id: 'smithy.api#Blob')
        Boolean = BooleanShape.new(id: 'smithy.api#Boolean')
        Byte = IntegerShape.new(id: 'smithy.api#Byte')
        Document = DocumentShape.new(id: 'smithy.api#Document')
        Double = FloatShape.new(id: 'smithy.api#Double')
        Float = FloatShape.new(id: 'smithy.api#Float')
        Integer = IntegerShape.new(id: 'smithy.api#Integer')
        Long = IntegerShape.new(id: 'smithy.api#Long')
        PrimitiveBoolean = BooleanShape.new(
          id: 'smithy.api#PrimitiveBoolean',
          traits: { 'smithy.api#default' => false }
        )
        PrimitiveByte = IntegerShape.new(
          id: 'smithy.api#PrimitiveByte',
          traits: { 'smithy.api#default' => 0 }
        )
        PrimitiveDouble = FloatShape.new(
          id: 'smithy.api#PrimitiveDouble',
          traits: { 'smithy.api#default' => 0 }
        )
        PrimitiveFloat = FloatShape.new(
          id: 'smithy.api#PrimitiveFloat',
          traits: { 'smithy.api#default' => 0 }
        )
        PrimitiveInteger = IntegerShape.new(
          id: 'smithy.api#PrimitiveInteger',
          traits: { 'smithy.api#default' => 0 }
        )
        PrimitiveShort = IntegerShape.new(
          id: 'smithy.api#PrimitiveShort',
          traits: { 'smithy.api#default' => 0 }
        )
        PrimitiveLong = IntegerShape.new(
          id: 'smithy.api#PrimitiveLong',
          traits: { 'smithy.api#default' => 0 }
        )
        Short = IntegerShape.new(id: 'smithy.api#Short')
        String = StringShape.new(id: 'smithy.api#String')
        Timestamp = TimestampShape.new(id: 'smithy.api#Timestamp')
        Unit = StructureShape.new(
          id: 'smithy.api#Unit',
          traits: { 'smithy.api#unitType' => {} }
        )
      end
    end
  end
end
