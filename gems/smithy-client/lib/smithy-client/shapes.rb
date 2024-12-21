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

        # @return [MemberShape, nil]
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
        def set_member(name, shape, traits: {})
          @member = MemberShape.new(name, shape, traits: traits)
        end
      end

      # Represents a Map shape
      class MapShape < Shape
        def initialize(options = {})
          super
          @member_key = nil
          @member_value = nil
        end

        # @return [MemberShape, nil]
        attr_accessor :member_key

        # @return [MemberShape, nil]
        attr_accessor :member_value

        # @return [MemberShape]
        def set_member_key(shape, traits: {})
          @member_key = MemberShape.new('key', shape, traits: traits)
        end

        # @return [MemberShape]
        def set_member_value(shape, traits: {})
          @member_value = MemberShape.new('value', shape, traits: traits)
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

      PreludeBigDecimal = IntegerShape.new(shape_id: 'smithy.api#BigDecimal')
      PreludeBigInteger = IntegerShape.new(shape_id: 'smithy.api#BigInteger')
      PreludeBlob = BlobShape.new(shape_id: 'smithy.api#Blob')
      PreludeBoolean = BooleanShape.new(shape_id: 'smithy.api#Boolean')
      PreludeByte = IntegerShape.new(shape_id: 'smithy.api#Byte')
      PreludeDocument = DocumentShape.new(shape_id: 'smithy.api#Document')
      PreludeDouble = FloatShape.new(shape_id: 'smithy.api#Double')
      PreludeFloat = FloatShape.new(shape_id: 'smithy.api#Float')
      PreludeInteger = IntegerShape.new(shape_id: 'smithy.api#Integer')
      PreludeLong = IntegerShape.new(shape_id: 'smithy.api#Long')
      PreludePrimitiveBoolean = BooleanShape.new(
        shape_id: 'smithy.api#PrimitiveBoolean',
        traits: { 'smithy.api#default' => false }
      )
      PreludePrimitiveByte = IntegerShape.new(
        shape_id: 'smithy.api#PrimitiveByte',
        traits: { 'smithy.api#default' => 0 }
      )
      PreludePrimitiveDouble = FloatShape.new(
        shape_id: 'smithy.api#PrimitiveDouble',
        traits: { 'smithy.api#default' => 0 }
      )
      PreludePrimitiveFloat = FloatShape.new(
        shape_id: 'smithy.api#PrimitiveFloat',
        traits: { 'smithy.api#default' => 0 }
      )
      PreludePrimitiveInteger = IntegerShape.new(
        shape_id: 'smithy.api#PrimitiveInteger',
        traits: { 'smithy.api#default' => 0 }
      )
      PreludePrimitiveShort = IntegerShape.new(
        shape_id: 'smithy.api#PrimitiveShort',
        traits: { 'smithy.api#default' => 0 }
      )
      PreludePrimitiveLong = IntegerShape.new(
        shape_id: 'smithy.api#PrimitiveLong',
        traits: { 'smithy.api#default' => 0 }
      )
      PreludeShort = IntegerShape.new(shape_id: 'smithy.api#Short')
      PreludeString = StringShape.new(shape_id: 'smithy.api#String')
      PreludeTimestamp = TimestampShape.new(shape_id: 'smithy.api#Timestamp')
      PreludeUnit = StructureShape.new(
        shape_id: 'smithy.api#Unit',
        traits: { 'smithy.api#unitType' => {} }
      )
    end
  end
end
