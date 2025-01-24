# frozen_string_literal: true

describe 'Component: Shapes' do
  before(:all) do
    @tmpdir = SpecHelper.generate(['ShapeService'], :client, fixture: 'shapes')
  end

  after(:all) do
    SpecHelper.cleanup(['ShapeService'], @tmpdir)
  end

  let(:fixture) { JSON.load_file(File.expand_path('../../fixtures/shapes/model.json', __dir__.to_s)) }
  let(:shapes_module) { Smithy::Client::Shapes }
  subject { ShapeService::Shapes }

  it 'generates a shapes module' do
    expect(subject).to be_a(Module)
  end

  context 'generated shapes' do
    context 'string' do
      let(:expected_shape) { fixture['shapes'].select { |_, s| s['type'] == 'string' } }

      it 'is an instance of StringShape' do
        expect(subject::String).to be_a(shapes_module::StringShape)
      end

      it 'has an id' do
        expect(subject::String.id).to eq(expected_shape.keys.first)
      end

      it 'has traits and does not contain omitted traits' do
        expected_traits =
          expected_shape
          .values
          .first['traits']
          .reject { |k, _| k.include?('documentation') }
        expect(subject::String.traits).to eq(expected_traits)
      end
    end

    it 'bigdecimal is an instance of BigDecimalShape' do
      expect(subject::BigDecimal).to be_a(shapes_module::BigDecimalShape)
    end

    it 'blob is an instance of BlobShape' do
      expect(subject::Blob).to be_a(shapes_module::BlobShape)
    end

    it 'boolean is an instance of BooleanShape' do
      expect(subject::Boolean).to be_a(shapes_module::BooleanShape)
    end

    it 'document is an instance of DocumentShape' do
      expect(subject::Document).to be_a(shapes_module::DocumentShape)
    end

    it 'float and double are instances of FloatShape' do
      expect(subject::Float).to be_a(shapes_module::FloatShape)
      expect(subject::Double).to be_a(shapes_module::FloatShape)
    end

    it 'numbers are instances of IntegerShape' do
      expect(subject::BigInteger).to be_a(shapes_module::IntegerShape)
      expect(subject::Byte).to be_a(shapes_module::IntegerShape)
      expect(subject::Integer).to be_a(shapes_module::IntegerShape)
      expect(subject::Long).to be_a(shapes_module::IntegerShape)
      expect(subject::Short).to be_a(shapes_module::IntegerShape)
    end

    it 'timestamp is an instance of TimestampShape' do
      expect(subject::Timestamp).to be_a(shapes_module::TimestampShape)
    end

    context 'enum' do
      let(:expected_member) do
        fixture['shapes']
          .select { |_, s| s['type'] == 'enum' }
          .values
          .first['members']['FOO']
      end

      it 'is an instance of EnumShape' do
        expect(subject::Enum).to be_a(shapes_module::EnumShape)
      end

      it 'has members' do
        expect(subject::Enum.members.keys).to eq(%i[foo])
        expect(subject::Enum.members[:foo]).to be_a(shapes_module::MemberShape)
        expect(subject::Enum.members[:foo].shape).to be_a(shapes_module::StructureShape)
        expect(subject::Enum.members[:foo].traits).to eq(expected_member['traits'])
        expect(subject::Enum.members[:foo].shape.id).to eq(expected_member['target'])
      end
    end

    context 'intEnum' do
      let(:expected_member) do
        fixture['shapes']
          .select { |_, s| s['type'] == 'intEnum' }
          .values
          .first['members']['BAZ']
      end

      it 'is an instance of IntEnumShape' do
        expect(subject::IntEnum).to be_a(shapes_module::IntEnumShape)
      end

      it 'has members' do
        expect(subject::IntEnum.members.keys).to eq(%i[baz])
        expect(subject::IntEnum.members[:baz]).to be_a(shapes_module::MemberShape)
        expect(subject::IntEnum.members[:baz].shape).to be_a(shapes_module::StructureShape)
        expect(subject::IntEnum.members[:baz].traits).to eq(expected_member['traits'])
        expect(subject::IntEnum.members[:baz].shape.id).to eq(expected_member['target'])
      end
    end

    context 'list' do
      let(:expected_member) do
        fixture['shapes']
          .select { |_, s| s['type'] == 'list' }
          .values
          .first['member']
      end

      it 'is an instance of ListShape' do
        expect(subject::List).to be_a(shapes_module::ListShape)
      end

      it 'has member' do
        expect(subject::List.member).to be_a(shapes_module::MemberShape)
        expect(subject::List.member.shape).to be_a(shapes_module::StringShape)
        expect(subject::List.member.shape.id).to eq(expected_member['target'])
      end
    end

    context 'map' do
      let(:expected_shape) do
        fixture['shapes']
          .select { |_, s| s['type'] == 'map' }
          .values
          .first
      end

      it 'is an instance of MapShape' do
        expect(subject::Map).to be_a(shapes_module::MapShape)
      end

      it 'has key and value members' do
        expect(subject::Map.key).to be_a(shapes_module::MemberShape)
        expect(subject::Map.key.shape).to be_a(shapes_module::StringShape)
        expect(subject::Map.key.shape.id).to eq(expected_shape['key']['target'])
        expect(subject::Map.value).to be_a(shapes_module::MemberShape)
        expect(subject::Map.value.shape).to be_a(shapes_module::IntegerShape)
        expect(subject::Map.value.shape.id).to eq(expected_shape['value']['target'])
      end
    end

    context 'structure' do
      let(:expected_shape) do
        fixture['shapes']
          .select { |k, _| k.include?('OperationInputOutput') }
          .values
          .first
      end

      it 'is an instance of StructureShape' do
        expect(subject::OperationInputOutput).to be_a(shapes_module::StructureShape)
      end

      it 'has a type' do
        expect(subject::OperationInputOutput.type).to eq(ShapeService::Types::OperationInputOutput)
      end

      it 'has members' do
        expected_members =
          expected_shape['members']
          .keys
          .map { |m| m.underscore.to_sym }
        expect(subject::OperationInputOutput.members.keys).to eq(expected_members)
      end

      it 'has a member with traits' do
        expected_member =
          expected_shape['members']
          .slice('id')
          .values
          .first
        expect(subject::OperationInputOutput.member(:id).traits).to eq(expected_member['traits'])
      end
    end

    context 'union' do
      it 'is an instance of UnionShape' do
        expect(subject::Union).to be_a(shapes_module::UnionShape)
      end
    end
  end

  context 'schema' do
    it 'is a schema' do
      expect(subject::SCHEMA).to be_a(Smithy::Client::Schema)
    end

    context 'service' do
      let(:service_shape) { subject::SCHEMA.service }
      let(:expected_service) { fixture['shapes'].find { |_k, v| v['type'] == 'service' } }

      it 'is a service shape and able to access service shape data' do
        expect(service_shape).to be_a(shapes_module::ServiceShape)
        expect(service_shape.id).to eql(expected_service[0])
        expect(service_shape.version).to eq(expected_service[1]['version'])

        if (expected_traits = expected_service[1]['traits'])
          expect(service_shape.traits).to include(expected_traits)
        end
      end
    end

    context 'operations' do
      let(:operations) { subject::SCHEMA.operations }
      let(:operation_shapes) { fixture.select { |_k, v| v['type'] == 'operation' } }

      it 'is not empty' do
        expect(operations).not_to be_empty
      end

      it 'made of operation shapes and able to access its contents' do
        operation_shapes.each do |name, shape|
          generated_shape = subject::SCHEMA.operation(name.underscore)

          expect(generated_shape.id).to eq(name)
          expect(generated_shape).to be_a(shapes_module::OperationShape)
          expect(generated_shape.input.id).to eq(shape['input'])
          expect(generated_shape.output.id).to eq(shape['output'])

          errors.each do |err|
            generated_error = generated_shape.errors.find { |s| s.id == err }
            expect(generated_error.id).to eq(err)
          end
        end
      end
    end
  end
end
