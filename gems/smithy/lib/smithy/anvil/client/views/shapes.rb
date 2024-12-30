# frozen_string_literal: true

module Smithy
  module Anvil
    module Client
      module Views
        # @api private
        class Shapes < View
          def initialize(plan)
            @plan = plan
            @model = plan.model
            @service_shape = assemble_service_shape
            @shapes, @operation_shapes = assemble_shapes
            super()
          end

          def namespace
            Tools::Namespace.namespace_from_gem_name(@plan.options[:gem_name])
          end

          def shapes_with_members
            @shapes.reject { |s| s.members.empty? }
          end

          private

          def assemble_service_shape
            shape = Vise::ServiceIndex.new(@model).service
            shape_data = shape.values.first

            ServiceShape.new(
              id: shape.keys.first,
              traits: filter_traits(shape_data['traits']),
              version: shape_data['version']
            )
          end

          def assemble_shapes
            serializable_shapes = []
            operation_shapes = []

            @model['shapes'].each do |id, shape|
              case shape['type']
              when 'service', 'resource' then next
              when 'operation'
                operation_shapes << assemble_operation_shape(id, shape)
              else
                serializable_shapes << assemble_shape(id, shape)
              end
            end

            [serializable_shapes, operation_shapes]
          end

          def assemble_operation_shape(id, shape)
            OperationShape.new(
              id: id,
              name: assemble_shape_name(id).underscore,
              input: assemble_shape_name(shape['input']['target']),
              output: assemble_shape_name(shape['output']['target']),
              errors: assemble_error_shapes(shape['errors']),
              traits: filter_traits(shape['traits'])
            )
          end

          def assemble_error_shapes(error_shapes)
            return [] if error_shapes.nil?

            error_shapes.each_with_object([]) do |err, a|
              a << assemble_shape_name(err['target'])
            end
          end

          def assemble_shape(id, shape)
            SerializableShape.new(
              id: id,
              name: Vise::Shape.relative_id(id),
              shape_type: shape_type(shape['type']),
              traits: filter_traits(shape['traits']),
              members: assemble_member_shapes(shape)
            )
          end

          def assemble_member_shapes(shape)
            members = []
            case shape['type']
            when 'structure', 'union', 'enum', 'intEnum'
              shape['members'].each do |name, shape|
                members <<
                  assemble_member_shape(name, shape['target'], shape['traits'])
              end
            when 'list'
              m_shape = shape['member']
              members <<
                assemble_member_shape('member', m_shape['target'], m_shape['traits'])
            when 'map'
              %w[key value].each do |m_name|
                m_shape = shape[m_name]
                members <<
                  assemble_member_shape(m_name, m_shape['target'], m_shape['traits'])
              end
            end
            members
          end

          def assemble_member_shape(name, shape, traits)
            MemberShape.new(
              name: name.underscore,
              shape: assemble_shape_name(shape),
              traits: filter_traits(traits)
            )
          end

          def assemble_shape_name(id)
            if PRELUDE_SHAPES_MAP.include?(id)
              PRELUDE_SHAPES_MAP[id]
            else
              Vise::Shape.relative_id(id)
            end
          end

          def filter_traits(traits)
            return {} unless traits

            traits.except(*OMITTED_TRAITS)
          end

          def shape_type(type)
            msg = "Unsupported shape type: `#{type}'"
            raise ArgumentError, msg unless SHAPE_CLASSES_MAP.include?(type)

            SHAPE_CLASSES_MAP[type]
          end

          # Shape that contains relevant data that affects (de)serialization
          class ServiceShape
            def initialize(options = {})
              @id = options[:id]
              @traits = options[:traits]
              @version = options[:version]
            end

            attr_reader :id, :traits, :version
          end

          # Shape that contains relevant data that affects (de)serialization
          class SerializableShape
            TYPED_SHAPES = %w[StructureShape UnionShape].freeze

            def initialize(options = {})
              @id = options[:id]
              @name = options[:name]
              @shape_type = options[:shape_type]
              @traits = options[:traits]
              @members = options[:members]
              @typed = TYPED_SHAPES.include?(@shape_type)
            end

            attr_reader :name, :id, :shape_type, :typed, :traits, :members
          end

          # Operation Shape that contains relevant data that affects (de)serialization
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

          # Member Shape that contains relevant data that affects (de)serialization
          class MemberShape
            def initialize(options = {})
              @name = options[:name]
              @shape = options[:shape]
              @traits = options[:traits]
            end

            attr_reader :name, :shape, :traits
          end

          OMITTED_TRAITS = %w[
            smithy.api#documentation
          ].freeze

          SHAPE_CLASSES_MAP = {
            'bigDecimal' => 'BigDecimal',
            'bigInteger' => 'IntegerShape',
            'blob' => 'BlobShape',
            'boolean' => 'BooleanShape',
            'byte' => 'IntegerShape',
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
            'short' => 'NumberShape',
            'string' => 'StringShape',
            'structure' => 'StructureShape',
            'timestamp' => 'TimestampShape',
            'union' => 'StructureShape'
          }.freeze

          PRELUDE_SHAPES_MAP = {
            'smithy.api#BigInteger' => 'BigInteger',
            'smithy.api#BigDecimal' => 'BigDecimal',
            'smithy.api#Blob' => 'Blob',
            'smithy.api#Boolean' => 'Boolean',
            'smithy.api#Byte' => 'Byte',
            'smithy.api#Document' => 'Document',
            'smithy.api#Double' => 'Double',
            'smithy.api#Float' => 'Float',
            'smithy.api#Integer' => 'Integer',
            'smithy.api#Long' => 'Long',
            'smithy.api#PrimitiveBoolean' => 'PrimitiveBoolean',
            'smithy.api#PrimitiveByte' => 'PrimitiveByte',
            'smithy.api#PrimitiveDouble' => 'PrimitiveDouble',
            'smithy.api#PrimitiveFloat' => 'PrimitiveFloat',
            'smithy.api#PrimitiveInteger' => 'PrimitiveInteger',
            'smithy.api#PrimitiveLong' => 'PrimitiveLong',
            'smithy.api#PrimitiveShort' => 'PrimitiveShort',
            'smithy.api#Short' => 'Short',
            'smithy.api#String' => 'String',
            'smithy.api#Timestamp' => 'Timestamp',
            'smithy.api#Unit' => 'Unit'
          }.freeze
        end
      end
    end
  end
end
