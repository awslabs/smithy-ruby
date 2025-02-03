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

  context 'blob' do
    it 'is an instance of BlobShape' do
      expect(subject::Blob).to be_a(shapes_module::BlobShape)
    end

    it 'has an id' do
      id, = fixture['shapes'].find { |_, s| s['type'] == 'blob' }
      expect(subject::Blob.id).to eq(id)
    end

    it 'has traits' do
      _, shape = fixture['shapes'].find { |_, s| s['type'] == 'blob' }
      expect(subject::Blob.traits).to eq(shape['traits'])
    end
  end

  context 'boolean' do
    it 'is an instance of BooleanShape' do
      expect(subject::Boolean).to be_a(shapes_module::BooleanShape)
    end

    it 'has an id' do
      id, = fixture['shapes'].find { |_, s| s['type'] == 'boolean' }
      expect(subject::Boolean.id).to eq(id)
    end

    it 'has traits' do
      _, shape = fixture['shapes'].find { |_, s| s['type'] == 'blob' }
      expect(subject::Boolean.traits).to eq(shape['traits'])
    end
  end

  context 'string' do
    it 'is an instance of StringShape' do
      expect(subject::String).to be_a(shapes_module::StringShape)
    end

    it 'has an id' do
      id, = fixture['shapes'].find { |_, s| s['type'] == 'string' }
      expect(subject::String.id).to eq(id)
    end

    it 'has traits' do
      _, shape = fixture['shapes'].find { |_, s| s['type'] == 'string' }
      expect(subject::String.traits).to eq(shape['traits'])
    end
  end

  context 'byte' do
    it 'is an instance of IntegerShape' do
      expect(subject::Byte).to be_a(shapes_module::IntegerShape)
    end

    it 'has an id' do
      id, = fixture['shapes'].find { |_, s| s['type'] == 'byte' }
      expect(subject::Byte.id).to eq(id)
    end

    it 'has traits' do
      _, shape = fixture['shapes'].find { |_, s| s['type'] == 'byte' }
      expect(subject::Byte.traits).to eq(shape['traits'])
    end
  end

  context 'short' do
    it 'is an instance of IntegerShape' do
      expect(subject::Short).to be_a(shapes_module::IntegerShape)
    end

    it 'has an id' do
      id, = fixture['shapes'].find { |_, s| s['type'] == 'short' }
      expect(subject::Short.id).to eq(id)
    end

    it 'has traits' do
      _, shape = fixture['shapes'].find { |_, s| s['type'] == 'short' }
      expect(subject::Short.traits).to eq(shape['traits'])
    end
  end

  context 'integer' do
    it 'is an instance of IntegerShape' do
      expect(subject::Integer).to be_a(shapes_module::IntegerShape)
    end

    it 'has an id' do
      id, = fixture['shapes'].find { |_, s| s['type'] == 'integer' }
      expect(subject::Integer.id).to eq(id)
    end

    it 'has traits' do
      _, shape = fixture['shapes'].find { |_, s| s['type'] == 'integer' }
      expect(subject::Integer.traits).to eq(shape['traits'])
    end
  end

  context 'long' do
    it 'is an instance of IntegerShape' do
      expect(subject::Long).to be_a(shapes_module::IntegerShape)
    end

    it 'has an id' do
      id, = fixture['shapes'].find { |_, s| s['type'] == 'long' }
      expect(subject::Long.id).to eq(id)
    end

    it 'has traits' do
      _, shape = fixture['shapes'].find { |_, s| s['type'] == 'long' }
      expect(subject::Long.traits).to eq(shape['traits'])
    end
  end

  context 'float' do
    it 'is an instance of FloatShape' do
      expect(subject::Float).to be_a(shapes_module::FloatShape)
    end

    it 'has an id' do
      id, = fixture['shapes'].find { |_, s| s['type'] == 'float' }
      expect(subject::Float.id).to eq(id)
    end

    it 'has traits' do
      _, shape = fixture['shapes'].find { |_, s| s['type'] == 'float' }
      expect(subject::Float.traits).to eq(shape['traits'])
    end
  end

  context 'double' do
    it 'is an instance of FloatShape' do
      expect(subject::Double).to be_a(shapes_module::FloatShape)
    end

    it 'has an id' do
      id, = fixture['shapes'].find { |_, s| s['type'] == 'double' }
      expect(subject::Double.id).to eq(id)
    end

    it 'has traits' do
      _, shape = fixture['shapes'].find { |_, s| s['type'] == 'double' }
      expect(subject::Double.traits).to eq(shape['traits'])
    end
  end

  context 'bigInteger' do
    it 'is an instance of IntegerShape' do
      expect(subject::BigInteger).to be_a(shapes_module::IntegerShape)
    end

    it 'has an id' do
      id, = fixture['shapes'].find { |_, s| s['type'] == 'bigInteger' }
      expect(subject::BigInteger.id).to eq(id)
    end

    it 'has traits' do
      _, shape = fixture['shapes'].find { |_, s| s['type'] == 'bigInteger' }
      expect(subject::BigInteger.traits).to eq(shape['traits'])
    end
  end

  context 'bigDecimal' do
    it 'is an instance of BigDecimalShape' do
      expect(subject::BigDecimal).to be_a(shapes_module::BigDecimalShape)
    end

    it 'has an id' do
      id, = fixture['shapes'].find { |_, s| s['type'] == 'bigDecimal' }
      expect(subject::BigDecimal.id).to eq(id)
    end

    it 'has traits' do
      _, shape = fixture['shapes'].find { |_, s| s['type'] == 'bigDecimal' }
      expect(subject::BigDecimal.traits).to eq(shape['traits'])
    end
  end

  context 'timestamp' do
    it 'is an instance of TimestampShape' do
      expect(subject::Timestamp).to be_a(shapes_module::TimestampShape)
    end

    it 'has an id' do
      id, = fixture['shapes'].find { |_, s| s['type'] == 'timestamp' }
      expect(subject::Timestamp.id).to eq(id)
    end

    it 'has traits' do
      _, shape = fixture['shapes'].find { |_, s| s['type'] == 'timestamp' }
      expect(subject::Timestamp.traits).to eq(shape['traits'])
    end
  end

  context 'document' do
    it 'is an instance of DocumentShape' do
      expect(subject::Document).to be_a(shapes_module::DocumentShape)
    end

    it 'has an id' do
      id, = fixture['shapes'].find { |_, s| s['type'] == 'document' }
      expect(subject::Document.id).to eq(id)
    end

    it 'has traits' do
      _, shape = fixture['shapes'].find { |_, s| s['type'] == 'document' }
      expect(subject::Document.traits).to eq(shape['traits'])
    end
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

    it 'has an id' do
      id, = fixture['shapes'].find { |_, s| s['type'] == 'enum' }
      expect(subject::Enum.id).to eq(id)
    end

    it 'has traits' do
      _, shape = fixture['shapes'].find { |_, s| s['type'] == 'enum' }
      expect(subject::Enum.traits).to eq(shape['traits'])
    end

    it 'has members' do
      expect(subject::Enum.members.keys).to eq(%i[foo])
      expect(subject::Enum.members[:foo]).to be_a(shapes_module::MemberShape)
      expect(subject::Enum.members[:foo].shape).to be_a(shapes_module::StructureShape)
      expect(subject::Enum.members[:foo].traits).to eq(expected_member['traits'])
      expect(subject::Enum.members[:foo].shape.id).to eq(expected_member['target'])
    end

    it 'has a member with traits' do
      expect(subject::Enum.member(:foo).traits).to eq(expected_member['traits'])
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

    it 'has an id' do
      id, = fixture['shapes'].find { |_, s| s['type'] == 'intEnum' }
      expect(subject::IntEnum.id).to eq(id)
    end

    it 'has traits' do
      _, shape = fixture['shapes'].find { |_, s| s['type'] == 'intEnum' }
      expect(subject::IntEnum.traits).to eq(shape['traits'])
    end

    it 'has members' do
      expect(subject::IntEnum.members.keys).to eq(%i[baz])
      expect(subject::IntEnum.members[:baz]).to be_a(shapes_module::MemberShape)
      expect(subject::IntEnum.members[:baz].shape).to be_a(shapes_module::StructureShape)
      expect(subject::IntEnum.members[:baz].traits).to eq(expected_member['traits'])
      expect(subject::IntEnum.members[:baz].shape.id).to eq(expected_member['target'])
    end

    it 'has a member with traits' do
      expect(subject::IntEnum.member(:baz).traits).to eq(expected_member['traits'])
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

    it 'has an id' do
      id, = fixture['shapes'].find { |_, s| s['type'] == 'list' }
      expect(subject::List.id).to eq(id)
    end

    it 'has traits' do
      _, shape = fixture['shapes'].find { |_, s| s['type'] == 'list' }
      expect(subject::List.traits).to eq(shape['traits'])
    end

    it 'has a member' do
      expect(subject::List.member).to be_a(shapes_module::MemberShape)
      expect(subject::List.member.shape).to be_a(shapes_module::StringShape)
      expect(subject::List.member.shape.id).to eq(expected_member['target'])
    end

    it 'has a member with traits' do
      expect(subject::List.member.traits).to eq(expected_member['traits'])
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

    it 'has an id' do
      id, = fixture['shapes'].find { |_, s| s['type'] == 'map' }
      expect(subject::Map.id).to eq(id)
    end

    it 'has traits' do
      _, shape = fixture['shapes'].find { |_, s| s['type'] == 'map' }
      expect(subject::Map.traits).to eq(shape['traits'])
    end

    it 'has key and value members' do
      expect(subject::Map.key).to be_a(shapes_module::MemberShape)
      expect(subject::Map.key.shape).to be_a(shapes_module::StringShape)
      expect(subject::Map.key.shape.id).to eq(expected_shape['key']['target'])
      expect(subject::Map.value).to be_a(shapes_module::MemberShape)
      expect(subject::Map.value.shape).to be_a(shapes_module::StringShape)
      expect(subject::Map.value.shape.id).to eq(expected_shape['value']['target'])
    end

    it 'has keys and values with traits' do
      expect(subject::Map.key.traits).to eq(expected_shape['key']['traits'])
      expect(subject::Map.value.traits).to eq(expected_shape['value']['traits'])
    end
  end

  context 'union' do
    let(:expected_shape) do
      fixture['shapes']
        .select { |k, _| k.include?('Union') }
        .values
        .first
    end

    it 'is an instance of UnionShape' do
      expect(subject::Union).to be_a(shapes_module::UnionShape)
    end

    it 'has an id' do
      id, = fixture['shapes'].find { |_, s| s['type'] == 'union' }
      expect(subject::Union.id).to eq(id)
    end

    it 'has traits' do
      _, shape = fixture['shapes'].find { |_, s| s['type'] == 'union' }
      expect(subject::Union.traits).to eq(shape['traits'])
    end

    it 'has members' do
      expected_members = expected_shape['members'].keys.map(&:to_sym)
      expect(subject::Union.members.keys).to eq(expected_members)
    end

    it 'has a member with traits' do
      expected_member = expected_shape['members'].slice('string').values.first
      expect(subject::Union.member(:string).traits).to eq(expected_member['traits'])
    end

    it 'has a type' do
      expect(subject::Union.type).to eq(ShapeService::Types::Union)
    end

    it 'has members with types' do
      expect(subject::Union.member(:string)).to be_a(shapes_module::MemberShape)
      expect(subject::Union.member_type(:string)).to eq(ShapeService::Types::Union::String)
    end
  end

  context 'structure' do
    let(:expected_shape) do
      fixture['shapes']
        .select { |k, _| k.include?('Structure') }
        .values
        .first
    end

    it 'is an instance of StructureShape' do
      expect(subject::Structure).to be_a(shapes_module::StructureShape)
    end

    it 'has an id' do
      id, = fixture['shapes'].find { |k, _| k.include?('Structure') }
      expect(subject::Structure.id).to eq(id)
    end

    it 'has traits' do
      _, shape = fixture['shapes'].find { |k, _| k.include?('Structure') }
      expect(subject::Structure.traits).to eq(shape['traits'])
    end

    it 'has members' do
      expected_members =
        expected_shape['members']
        .keys
        .map { |m| m.underscore.to_sym }
      expect(subject::Structure.members.keys).to eq(expected_members)
    end

    it 'has a member with traits' do
      expected_member =
        expected_shape['members']
        .slice('member')
        .values
        .first
      expect(subject::Structure.member(:member).traits).to eq(expected_member['traits'])
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
          expect(generated_shape.traits).to eq(shape['traits'])
          expect(generated_shape.errors.map(&:id)).to eq(shape['errors'])
        end
      end
    end
  end
end
