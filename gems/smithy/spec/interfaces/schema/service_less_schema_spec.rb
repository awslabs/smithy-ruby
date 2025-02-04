# frozen_string_literal: true

describe 'Service-Less Schema', rbs_test: true do
  before(:all) do
    @tmpdir = SpecHelper.generate(['NoService'], :schema, fixture: 'no_service')
  end

  after(:all) do
    SpecHelper.cleanup(['NoService'], @tmpdir)
  end

  it 'generates a shapes module' do
    expect(NoService::Shapes).to be_a(Module)
  end

  it 'generates shapes' do
    expect(NoService::Shapes.constants)
      .to include(
        :List, :Enum, :BigDecimal, :BigInteger, :Blob, :Integer, :Byte,
        :Document, :Double, :Long, :Map, :IntEnum, :OperationInputOutput,
        :Float, :Timestamp, :Short, :Boolean, :Union, :String, :Structure
      )
  end

  it 'generates a schema with operations and no service' do
    expect(NoService::Shapes::SCHEMA).to be_a(Smithy::Client::Schema)
    expect(NoService::Shapes::SCHEMA.service).to be_nil
    expect(NoService::Shapes::SCHEMA.operations).to include(operation: be_a(Smithy::Client::Shapes::OperationShape))
  end
end
