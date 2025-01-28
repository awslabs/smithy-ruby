# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class Shapes < View
        def initialize(plan)
          @plan = plan
          @model = plan.model
          @service_shape = @plan.service
          @service_index = Model::ServiceIndex.new(@model)
          super()
        end

        def namespace
          @plan.gem_namespace
        end

        def operation_shapes
          @service_index
            .operations_for(@service_shape)
            .map { |k, v| build_operation_shape(k, v) }
        end

        def service_shape
          ServiceShape.new(
            id: @service_shape.keys.first,
            traits: filter_traits(@service_shape.values.first['traits']),
            version: @service_shape.values.first['version']
          )
        end

        def shapes_with_members
          complex = %w[EnumShape IntEnumShape ListShape MapShape StructureShape UnionShape]
          @shapes.select { |s| complex.include?(s.type) }
        end

        def shapes
          @shapes =
            @service_index
            .shapes_for(@service_shape)
            .reject { |_k, v| %w[operation resource service].include?(v['type']) }
            .map { |k, v| build_shape(k, v) }
        end

        private

        def build_operation_shape(id, shape)
          OperationShape.new(
            id: id,
            name: Model::Shape.name(id).underscore,
            input: shape_type_from_id(shape['input']['target']),
            output: shape_type_from_id(shape['output']['target']),
            errors: build_error_shapes(shape['errors']),
            traits: filter_traits(shape['traits'])
          )
        end

        def build_error_shapes(errors)
          return [] if errors.nil?

          errors.map { |err| Model::Shape.relative_id(err['target']) }
        end

        def build_shape(id, shape)
          Shape.new(
            id: id,
            name: Model::Shape.name(id),
            type: shape_type_from_type(shape['type']),
            traits: filter_traits(shape['traits']),
            members: build_member_shapes(shape)
          )
        end

        def build_member_shapes(shape)
          case shape['type']
          when 'enum', 'intEnum', 'structure', 'union'
            build_members(shape)
          when 'list'
            build_list_member(shape)
          when 'map'
            build_map_members(shape)
          else
            []
          end
        end

        def build_members(shape)
          shape['members'].map { |k, v| build_member_shape(k, v['target'], v['traits']) }
        end

        def build_list_member(shape)
          m_shape = shape['member']
          [] << build_member_shape('member', m_shape['target'], m_shape['traits'])
        end

        def build_map_members(shape)
          %w[key value].map do |m_name|
            m_shape = shape[m_name]
            build_member_shape(m_name, m_shape['target'], m_shape['traits'])
          end
        end

        def build_member_shape(name, id, traits)
          MemberShape.new(
            name: name.underscore,
            shape: shape_type_from_id(id),
            traits: filter_traits(traits)
          )
        end

        def filter_traits(traits)
          return {} unless traits

          traits.except(*OMITTED_TRAITS)
        end

        def shape_type_from_type(type)
          msg = "Unsupported shape type: `#{type}'"
          raise ArgumentError, msg unless SHAPE_TYPES_MAP.include?(type)

          SHAPE_TYPES_MAP[type]
        end

        def shape_type_from_id(id)
          return PRELUDE_SHAPES_MAP[id] if PRELUDE_SHAPES_MAP.key?(id)

          Model::Shape.relative_id(id)
        end

        # Service shape represents a slim Smithy service shape
        class ServiceShape
          def initialize(options = {})
            @id = options[:id]
            @traits = options[:traits]
            @version = options[:version]
          end

          attr_reader :id, :traits, :version
        end

        # Shape represents a Smithy shape
        class Shape
          TYPED_SHAPES = %w[StructureShape UnionShape].freeze

          def initialize(options = {})
            @id = options[:id]
            @name = options[:name]
            @type = options[:type]
            @traits = options[:traits]
            @members = options[:members]
            @typed = TYPED_SHAPES.include?(@type)
          end

          attr_reader :name, :id, :type, :typed, :traits, :members

          def new_method
            traits_str = ", traits: #{@traits}" unless @traits.empty?
            "new(id: '#{@id}'#{traits_str})"
          end
        end

        # Operation Shape represents Smithy operation shape
        class OperationShape
          def initialize(options = {})
            @id = options[:id]
            @name = options[:name]
            @input = options[:input]
            @output = options[:output]
            @errors = options[:errors]
            @traits = options[:traits]
          end

          attr_reader :id, :name, :input, :output, :errors, :traits
        end

        # Member Shape represents members of Smithy shape
        class MemberShape
          def initialize(options = {})
            @name = options[:name]
            @shape = options[:shape]
            @traits = options[:traits]
          end

          def add_member_method(shape)
            traits_str = ", traits: #{@traits}" unless @traits.empty?
            case shape
            when 'ListShape'
              "set_member(#{@shape}#{traits_str})"
            when 'MapShape'
              "set_#{@name}(#{@shape}#{traits_str})"
            else
              "add_member(:#{@name}, #{@shape}#{traits_str})"
            end
          end
        end

        # Traits that are handled in code generation
        OMITTED_TRAITS = %w[
          smithy.api#documentation
          smithy.api#examples
          smithy.rules#endpointRuleSet
          smithy.rules#endpointTests
        ].freeze

        SHAPE_TYPES_MAP = {
          'bigDecimal' => 'BigDecimalShape',
          'bigInteger' => 'IntegerShape',
          'blob' => 'BlobShape',
          'boolean' => 'BooleanShape',
          'byte' => 'IntegerShape',
          'document' => 'DocumentShape',
          'double' => 'FloatShape',
          'enum' => 'EnumShape',
          'float' => 'FloatShape',
          'integer' => 'IntegerShape',
          'intEnum' => 'IntEnumShape',
          'list' => 'ListShape',
          'long' => 'IntegerShape',
          'map' => 'MapShape',
          'operation' => 'OperationShape',
          'service' => 'ServiceShape',
          'short' => 'IntegerShape',
          'string' => 'StringShape',
          'structure' => 'StructureShape',
          'timestamp' => 'TimestampShape',
          'union' => 'UnionShape'
        }.freeze

        PRELUDE_SHAPES_MAP = {
          'smithy.api#BigInteger' => 'Prelude::BigInteger',
          'smithy.api#BigDecimal' => 'Prelude::BigDecimal',
          'smithy.api#Blob' => 'Prelude::Blob',
          'smithy.api#Boolean' => 'Prelude::Boolean',
          'smithy.api#Byte' => 'Prelude::Byte',
          'smithy.api#Document' => 'Prelude::Document',
          'smithy.api#Double' => 'Prelude::Double',
          'smithy.api#Float' => 'Prelude::Float',
          'smithy.api#Integer' => 'Prelude::Integer',
          'smithy.api#Long' => 'Prelude::Long',
          'smithy.api#PrimitiveBoolean' => 'Prelude::PrimitiveBoolean',
          'smithy.api#PrimitiveByte' => 'Prelude::PrimitiveByte',
          'smithy.api#PrimitiveDouble' => 'Prelude::PrimitiveDouble',
          'smithy.api#PrimitiveFloat' => 'Prelude::PrimitiveFloat',
          'smithy.api#PrimitiveInteger' => 'Prelude::PrimitiveInteger',
          'smithy.api#PrimitiveLong' => 'Prelude::PrimitiveLong',
          'smithy.api#PrimitiveShort' => 'Prelude::PrimitiveShort',
          'smithy.api#Short' => 'Prelude::Short',
          'smithy.api#String' => 'Prelude::String',
          'smithy.api#Timestamp' => 'Prelude::Timestamp',
          'smithy.api#Unit' => 'Prelude::Unit'
        }.freeze
      end
    end
  end
end
