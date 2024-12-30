# frozen_string_literal: true

module Smithy
  module Client
    # Represents shape types from Smithy Model
    module Shapes
      # A base shape that all shapes inherits from
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

      # Represents a slim variation of the Service shape
      class ServiceShape < Shape
        def initialize(options = {})
          super
          @version = options[:version]
        end

        # @return [String, nil]
        attr_accessor :version
      end

      # Represents an Operation shape
      class OperationShape < Shape
        def initialize(options = {})
          super
          @input = options[:input]
          @output = options[:output]
          @errors = options[:errors] || []
          yield self if block_given?
        end

        # @return [StructureShape, nil]
        attr_accessor :input

        # @return [StructureShape, nil]
        attr_accessor :output

        # @return [Array<StructureShape>]
        attr_accessor :errors
      end

      # Represents BigDecimal shape
      class BigDecimalShape < Shape; end

      # Represents both Blob and Data Stream shapes
      class BlobShape < Shape; end

      # Represents a Boolean shape
      class BooleanShape < Shape; end

      # Represents a Document shape
      class DocumentShape < Shape; end

      # Represents an Enum shape
      class EnumShape < Shape
        def initialize(options = {})
          super
          @members = {}
        end

        # @return [Hash<String, MemberShape>]
        attr_accessor :members

        # @return [MemberShape]
        def add_member(name, shape, traits: {})
          @members[name] = MemberShape.new(name, shape, traits: traits)
        end
      end

      # Represents the following shapes:
      # Byte, Short, Integer, Long, BigInteger
      class IntegerShape < Shape; end

      # Represents an IntEnum shape
      class IntEnumShape < EnumShape; end

      # Represents both Float and double shapes
      class FloatShape < Shape; end

      # Represents a List shape
      class ListShape < Shape
        def initialize(options = {})
          super
          @member = nil
        end

        # @return [MemberShape, nil]
        attr_accessor :member

        # @return [MemberShape]
        def set_member(shape, traits: {})
          @member = MemberShape.new('member', shape, traits: traits)
        end
      end

      # Represents a Map shape
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
          @key = MemberShape.new('key', shape, traits: traits)
        end

        # @return [MemberShape]
        def set_value(shape, traits: {})
          @value = MemberShape.new('value', shape, traits: traits)
        end
      end

      # Represents the String shape
      class StringShape < Shape; end

      # Represents the Structure shape
      class StructureShape < Shape
        def initialize(options = {})
          super
          @members = {}
          @type = options[:type]
        end

        # @return [Hash<String, MemberShape>]
        attr_accessor :members

        # @return [Types]
        attr_accessor :type

        # @return [MemberShape]
        def add_member(name, shape, traits: {})
          @members[name] = MemberShape.new(name, shape, traits: traits)
        end
      end

      # Represents the Timestamp shape
      class TimestampShape < Shape; end

      # Represents both Union and Eventstream shapes
      class UnionShape < StructureShape; end

      # Represents a member shape
      class MemberShape
        def initialize(name, shape, traits: {})
          @name = name
          @shape = shape
          @traits = traits
        end

        # @return [String]
        attr_accessor :name

        # @return [Shape]
        attr_accessor :shape

        # @return [Hash<String, Object>]
        attr_accessor :traits
      end

      BigDecimal = BigDecimalShape.new(shape_id: 'smithy.api#BigDecimal')
      BigInteger = IntegerShape.new(shape_id: 'smithy.api#BigInteger')
      Blob = BlobShape.new(shape_id: 'smithy.api#Blob')
      Boolean = BooleanShape.new(shape_id: 'smithy.api#Boolean')
      Byte = IntegerShape.new(shape_id: 'smithy.api#Byte')
      Document = DocumentShape.new(shape_id: 'smithy.api#Document')
      Double = FloatShape.new(shape_id: 'smithy.api#Double')
      Float = FloatShape.new(shape_id: 'smithy.api#Float')
      Integer = IntegerShape.new(shape_id: 'smithy.api#Integer')
      Long = IntegerShape.new(shape_id: 'smithy.api#Long')
      PrimitiveBoolean = BooleanShape.new(
        shape_id: 'smithy.api#PrimitiveBoolean',
        traits: { 'smithy.api#default' => false }
      )
      PrimitiveByte = IntegerShape.new(
        shape_id: 'smithy.api#PrimitiveByte',
        traits: { 'smithy.api#default' => 0 }
      )
      PrimitiveDouble = FloatShape.new(
        shape_id: 'smithy.api#PrimitiveDouble',
        traits: { 'smithy.api#default' => 0 }
      )
      PrimitiveFloat = FloatShape.new(
        shape_id: 'smithy.api#PrimitiveFloat',
        traits: { 'smithy.api#default' => 0 }
      )
      PrimitiveInteger = IntegerShape.new(
        shape_id: 'smithy.api#PrimitiveInteger',
        traits: { 'smithy.api#default' => 0 }
      )
      PrimitiveShort = IntegerShape.new(
        shape_id: 'smithy.api#PrimitiveShort',
        traits: { 'smithy.api#default' => 0 }
      )
      PrimitiveLong = IntegerShape.new(
        shape_id: 'smithy.api#PrimitiveLong',
        traits: { 'smithy.api#default' => 0 }
      )
      Short = IntegerShape.new(shape_id: 'smithy.api#Short')
      String = StringShape.new(shape_id: 'smithy.api#String')
      Timestamp = TimestampShape.new(shape_id: 'smithy.api#Timestamp')
      Unit = StructureShape.new(
        shape_id: 'smithy.api#Unit',
        traits: { 'smithy.api#unitType' => {} }
      )
    end
  end
end
