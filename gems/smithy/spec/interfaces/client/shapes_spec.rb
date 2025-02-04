# frozen_string_literal: true

describe 'Component: Shapes', rbs_test: true do
  before(:all) do
    @tmpdir = SpecHelper.generate(['ShapeService'], :client, fixture: 'shapes')
  end

  after(:all) do
    SpecHelper.cleanup(['ShapeService'], @tmpdir)
  end

  let(:fixture) { JSON.load_file(File.expand_path('../../fixtures/shapes/model.json', __dir__.to_s)) }

  subject { ShapeService::Shapes }

  it 'generates a shapes module' do
    expect(ShapeService::Shapes).to be_a(Module)
  end

  def expect_generated_shape(subject, shape_class, shape_hash)
    id, shape = shape_hash
    expect(subject).to be_a(shape_class)
    expect(subject.id).to eq(id)
    expect(subject.traits).to eq(shape['traits'])
  end

  context 'blob' do
    subject { ShapeService::Shapes::Blob }
    let(:shape_class) { Smithy::Client::Shapes::BlobShape }
    let(:shape_hash) do
      fixture['shapes'].find { |_, s| s['type'] == 'blob' }
    end

    it 'generates a blob shape' do
      expect_generated_shape(subject, shape_class, shape_hash)
    end
  end

  context 'boolean' do
    subject { ShapeService::Shapes::Boolean }
    let(:shape_class) { Smithy::Client::Shapes::BooleanShape }
    let(:shape_hash) do
      fixture['shapes'].find { |_, s| s['type'] == 'boolean' }
    end

    it 'generates a boolean shape' do
      expect_generated_shape(subject, shape_class, shape_hash)
    end
  end

  context 'string' do
    subject { ShapeService::Shapes::String }
    let(:shape_class) { Smithy::Client::Shapes::StringShape }
    let(:shape_hash) do
      fixture['shapes'].find { |_, s| s['type'] == 'string' }
    end

    it 'generates a string shape' do
      expect_generated_shape(subject, shape_class, shape_hash)
    end
  end

  context 'byte' do
    subject { ShapeService::Shapes::Byte }
    let(:shape_class) { Smithy::Client::Shapes::IntegerShape }
    let(:shape_hash) do
      fixture['shapes'].find { |_, s| s['type'] == 'byte' }
    end

    it 'generates a byte shape' do
      expect_generated_shape(subject, shape_class, shape_hash)
    end
  end

  context 'short' do
    subject { ShapeService::Shapes::Short }
    let(:shape_class) { Smithy::Client::Shapes::IntegerShape }
    let(:shape_hash) do
      fixture['shapes'].find { |_, s| s['type'] == 'short' }
    end

    it 'generates a short shape' do
      expect_generated_shape(subject, shape_class, shape_hash)
    end
  end

  context 'integer' do
    subject { ShapeService::Shapes::Integer }
    let(:shape_class) { Smithy::Client::Shapes::IntegerShape }
    let(:shape_hash) do
      fixture['shapes'].find { |_, s| s['type'] == 'integer' }
    end

    it 'generates an integer shape' do
      expect_generated_shape(subject, shape_class, shape_hash)
    end
  end

  context 'long' do
    subject { ShapeService::Shapes::Long }
    let(:shape_class) { Smithy::Client::Shapes::IntegerShape }
    let(:shape_hash) do
      fixture['shapes'].find { |_, s| s['type'] == 'long' }
    end

    it 'generates a long shape' do
      expect_generated_shape(subject, shape_class, shape_hash)
    end
  end

  context 'float' do
    subject { ShapeService::Shapes::Float }
    let(:shape_class) { Smithy::Client::Shapes::FloatShape }
    let(:shape_hash) do
      fixture['shapes'].find { |_, s| s['type'] == 'float' }
    end

    it 'generates a float shape' do
      expect_generated_shape(subject, shape_class, shape_hash)
    end
  end

  context 'double' do
    subject { ShapeService::Shapes::Double }
    let(:shape_class) { Smithy::Client::Shapes::FloatShape }
    let(:shape_hash) do
      fixture['shapes'].find { |_, s| s['type'] == 'double' }
    end

    it 'generates a double shape' do
      expect_generated_shape(subject, shape_class, shape_hash)
    end
  end

  context 'bigInteger' do
    subject { ShapeService::Shapes::BigInteger }
    let(:shape_class) { Smithy::Client::Shapes::IntegerShape }
    let(:shape_hash) do
      fixture['shapes'].find { |_, s| s['type'] == 'bigInteger' }
    end

    it 'generates a big integer shape' do
      expect_generated_shape(subject, shape_class, shape_hash)
    end
  end

  context 'bigDecimal' do
    subject { ShapeService::Shapes::BigDecimal }
    let(:shape_class) { Smithy::Client::Shapes::BigDecimalShape }
    let(:shape_hash) do
      fixture['shapes'].find { |_, s| s['type'] == 'bigDecimal' }
    end

    it 'generates a big decimal shape' do
      expect_generated_shape(subject, shape_class, shape_hash)
    end
  end

  context 'timestamp' do
    subject { ShapeService::Shapes::Timestamp }
    let(:shape_class) { Smithy::Client::Shapes::TimestampShape }
    let(:shape_hash) do
      fixture['shapes'].find { |_, s| s['type'] == 'timestamp' }
    end

    it 'generates a timestamp shape' do
      expect_generated_shape(subject, shape_class, shape_hash)
    end
  end

  context 'document' do
    subject { ShapeService::Shapes::Document }
    let(:shape_class) { Smithy::Client::Shapes::DocumentShape }
    let(:shape_hash) do
      fixture['shapes'].find { |_, s| s['type'] == 'document' }
    end

    it 'generates a document shape' do
      expect_generated_shape(subject, shape_class, shape_hash)
    end
  end

  context 'enum' do
    subject { ShapeService::Shapes::Enum }
    let(:shape_class) { Smithy::Client::Shapes::EnumShape }
    let(:shape_hash) do
      fixture['shapes'].find { |_, s| s['type'] == 'enum' }
    end
    let(:expected_member) do
      _, shape = shape_hash
      shape['members']['FOO']
    end

    it 'generates an enum shape' do
      expect_generated_shape(subject, shape_class, shape_hash)
    end

    it 'has members' do
      expect(subject.members.keys).to eq(%i[foo])
      expect(subject.members[:foo]).to be_a(Smithy::Client::Shapes::MemberShape)
      expect(subject.members[:foo].shape).to be_a(Smithy::Client::Shapes::StructureShape)
      expect(subject.members[:foo].traits).to eq(expected_member['traits'])
      expect(subject.members[:foo].shape.id).to eq(expected_member['target'])
    end

    it 'has a member with traits' do
      expect(subject.member(:foo).traits).to eq(expected_member['traits'])
    end
  end

  context 'intEnum' do
    subject { ShapeService::Shapes::IntEnum }
    let(:shape_class) { Smithy::Client::Shapes::IntEnumShape }
    let(:shape_hash) do
      fixture['shapes'].find { |_, s| s['type'] == 'intEnum' }
    end
    let(:expected_member) do
      _, shape = shape_hash
      shape['members']['BAZ']
    end

    it 'generates an int enum shape' do
      expect_generated_shape(subject, shape_class, shape_hash)
    end

    it 'has members' do
      expect(subject.members.keys).to eq(%i[baz])
      expect(subject.members[:baz]).to be_a(Smithy::Client::Shapes::MemberShape)
      expect(subject.members[:baz].shape).to be_a(Smithy::Client::Shapes::StructureShape)
      expect(subject.members[:baz].traits).to eq(expected_member['traits'])
      expect(subject.members[:baz].shape.id).to eq(expected_member['target'])
    end

    it 'has a member with traits' do
      expect(subject.member(:baz).traits).to eq(expected_member['traits'])
    end
  end

  context 'list' do
    subject { ShapeService::Shapes::List }
    let(:shape_class) { Smithy::Client::Shapes::ListShape }
    let(:shape_hash) do
      fixture['shapes'].find { |_, s| s['type'] == 'list' }
    end
    let(:expected_member) do
      _, shape = shape_hash
      shape['member']
    end

    it 'generates a list shape' do
      expect_generated_shape(subject, shape_class, shape_hash)
    end

    it 'has a member' do
      expect(subject.member).to be_a(Smithy::Client::Shapes::MemberShape)
      expect(subject.member.shape).to be_a(Smithy::Client::Shapes::StringShape)
      expect(subject.member.shape.id).to eq(expected_member['target'])
    end

    it 'has a member with traits' do
      expect(subject.member.traits).to eq(expected_member['traits'])
    end
  end

  context 'map' do
    subject { ShapeService::Shapes::Map }
    let(:shape_class) { Smithy::Client::Shapes::MapShape }
    let(:shape_hash) do
      fixture['shapes'].find { |_, s| s['type'] == 'map' }
    end
    let(:expected_shape) do
      _, shape = shape_hash
      shape
    end

    it 'generates a map shape' do
      expect_generated_shape(subject, shape_class, shape_hash)
    end

    it 'has key and value members' do
      expect(subject.key).to be_a(Smithy::Client::Shapes::MemberShape)
      expect(subject.key.shape).to be_a(Smithy::Client::Shapes::StringShape)
      expect(subject.key.shape.id).to eq(expected_shape['key']['target'])
      expect(subject.value).to be_a(Smithy::Client::Shapes::MemberShape)
      expect(subject.value.shape).to be_a(Smithy::Client::Shapes::StringShape)
      expect(subject.value.shape.id).to eq(expected_shape['value']['target'])
    end

    it 'has keys and values with traits' do
      expect(subject.key.traits).to eq(expected_shape['key']['traits'])
      expect(subject.value.traits).to eq(expected_shape['value']['traits'])
    end
  end

  context 'union' do
    subject { ShapeService::Shapes::Union }
    let(:shape_class) { Smithy::Client::Shapes::UnionShape }
    let(:shape_hash) do
      fixture['shapes'].find { |_, s| s['type'] == 'union' }
    end
    let(:expected_shape) do
      _, shape = shape_hash
      shape
    end

    it 'generates a union shape' do
      expect_generated_shape(subject, shape_class, shape_hash)
    end

    it 'has members' do
      expected_members = expected_shape['members'].keys.map(&:to_sym)
      expect(subject.members.keys).to eq(expected_members)
    end

    it 'has a member with traits' do
      expected_member = expected_shape['members'].slice('string').values.first
      expect(subject.member(:string).traits).to eq(expected_member['traits'])
    end

    it 'has a type' do
      expect(subject.type).to eq(ShapeService::Types::Union)
    end

    it 'has members with types' do
      expect(subject.member(:string)).to be_a(Smithy::Client::Shapes::MemberShape)
      expect(subject.member_type(:string)).to eq(ShapeService::Types::Union::String)
    end
  end

  context 'structure' do
    subject { ShapeService::Shapes::Structure }
    let(:shape_class) { Smithy::Client::Shapes::StructureShape }
    let(:shape_hash) do
      fixture['shapes'].find { |k, _| k.include?('Structure') }
    end
    let(:expected_shape) do
      _, shape = shape_hash
      shape
    end

    it 'generates a structure shape' do
      expect_generated_shape(subject, shape_class, shape_hash)
    end

    it 'has members' do
      expected_members =
        expected_shape['members']
        .keys
        .map { |m| m.underscore.to_sym }
      expect(subject.members.keys).to eq(expected_members)
    end

    it 'has a member with traits' do
      expected_member =
        expected_shape['members']
        .slice('member')
        .values
        .first
      expect(subject.member(:member).traits).to eq(expected_member['traits'])
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
        expect(service_shape).to be_a(Smithy::Client::Shapes::ServiceShape)
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
