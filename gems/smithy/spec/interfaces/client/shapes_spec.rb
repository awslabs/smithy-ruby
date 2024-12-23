# frozen_string_literal: true

describe 'Component: Shapes' do
  before(:all) do
    @tmpdir = SpecHelper.generate(['Weather'], :client)
  end

  after(:all) do
    SpecHelper.cleanup(['Weather'], @tmpdir)
  end

  subject { Weather::Shapes }
  let(:smithy_shapes) { Smithy::Client::Shapes }

  it 'generates a shapes module' do
    expect(Weather::Shapes).to be_a(Module)
  end

  context 'shapes' do
    it 'generates a shape with id and traits' do
      expect(subject::CityId).to be_a(smithy_shapes::StringShape)
      expect(subject::CityId.id).to eq('example.weather#CityId')
      expect(subject::CityId.traits.keys).to include('smithy.api#pattern')
    end

    it 'generates a shape with members with type and the members ' \
       'contains their own shape and traits' do
      expect(subject::CityCoordinates).to be_a(smithy_shapes::StructureShape)
      expect(subject::CityCoordinates.type).to be(Weather::Types::CityCoordinates)
      expect(subject::CityCoordinates.members.keys).to include('latitude', 'longitude')
      expect(subject::CityCoordinates.members['latitude'].shape).to be(smithy_shapes::PreludeFloat)
      expect(subject::CityCoordinates.members['latitude'].traits.keys).to include('smithy.api#required')
    end

    it 'does not include omitted traits' do
      expect(subject::CityCoordinates.traits.keys).not_to include('smithy.api#documentation')
    end
  end

  context 'schema' do
    it 'is a schema' do
      expect(subject::SCHEMA).to be_a(Smithy::Client::Schema)
    end

    it 'has a service and able to access service shape data' do
      expect(subject::SCHEMA.service).to be_a(smithy_shapes::ServiceShape)
      expect(subject::SCHEMA.service.id).to eq('example.weather#Weather')
      expect(subject::SCHEMA.service.version).to eq('2006-03-01')
      expect(subject::SCHEMA.service.traits).not_to be_empty
    end

    context 'operations' do
      it 'is not empty' do
        expect(subject::SCHEMA.operations).not_to be_empty
      end

      it 'able to access the operation shape data' do
        operation = subject::SCHEMA.operation(:get_city)
        expect(operation).to be_a(smithy_shapes::OperationShape)
        expect(operation.id).to eq('example.weather#GetCity')
        expect(operation.input).to eq(subject::GetCityInput)
        expect(operation.output).to eq(subject::GetCityOutput)
        expect(operation.errors).to include(subject::NoSuchResource)
        expect(operation.traits).not_to be_empty
      end
    end
  end
end
