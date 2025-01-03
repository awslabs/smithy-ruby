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
            @service_shape = @plan.service
            @service_index = Vise::ServiceIndex.new(@model)
            super()
          end

          def namespace
            Tools::Namespace.namespace_from_gem_name(@plan.options[:gem_name])
          end

          def operation_shapes
            @service_index.operations_for(@service_shape)
                          .each_with_object([]) do |(k, v), arr|
              arr << build_operation_shape(k, v)
            end
          end

          def service_shape
            ServiceShape.new(
              id: @service_shape.keys.first,
              traits: filter_traits(@service_shape.values.first['traits']),
              version: @service_shape.values.first['version']
            )
          end

          def shapes_with_members
            @shapes.select do |s|
              %w[EnumShape IntEnumShape ListShape MapShape StructureShape UnionShape]
                .include?(s.type)
            end
          end

          def shapes
            @shapes =
              @service_index
              .shapes_for(@service_shape)
              .each_with_object([]) do |(k, v), arr|
                next if %w[operation resource service].include?(v['type'])

                arr << build_shape(k, v)
              end
          end

          private

          def build_operation_shape(id, shape)
            OperationShape.new(
              id: id,
              name: build_shape_name(id).underscore,
              input: build_shape_name(shape['input']['target']),
              output: build_shape_name(shape['output']['target']),
              errors: build_error_shapes(shape['errors']),
              traits: filter_traits(shape['traits'])
            )
          end

          def build_error_shapes(errors)
            return [] if errors.nil?

            errors.each_with_object([]) do |err, a|
              a << build_shape_name(err['target'])
            end
          end

          def build_shape(id, shape)
            Shape.new(
              id: id,
              name: Vise::Shape.relative_id(id),
              type: shape_type(shape['type']),
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
            shape['members'].each_with_object([]) do |(k, v), arr|
              arr << build_member_shape(k, v['target'], v['traits'])
            end
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

          def build_member_shape(name, shape, traits)
            MemberShape.new(
              name: name.underscore,
              shape: build_shape_name(shape),
              traits: filter_traits(traits)
            )
          end

          def build_shape_name(id)
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

            attr_reader :name, :shape, :traits
          end

          # Traits that does not affect runtime
          OMITTED_TRAITS = %w[
            smithy.api#documentation
            smithy.rules#endpointRuleSet
            smithy.rules#endpointTest
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
            'union' => 'UnionShape'
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
