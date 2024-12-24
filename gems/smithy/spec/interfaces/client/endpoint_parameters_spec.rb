# frozen_string_literal: true

describe 'Component: EndpointParameters' do
  before(:all) do
    @tmpdir = SpecHelper.generate(['EndpointBindings'], :client, fixture: 'endpoints/endpoint-bindings')
  end

  after(:all) do
    SpecHelper.cleanup(['EndpointBindings'], @tmpdir)
  end

  subject { EndpointBindings::EndpointParameters.new }

  describe '#initialize' do
    it 'initializes with default values' do
      expect(subject.baz).to eq('baz')
      expect(subject.boolean_param).to eq(true)
      expect(subject.endpoint).to be_nil
      expect(subject.bar).to be_nil
    end
  end

  describe '.create' do
    it 'creates with default values and values from config' do
      # need to get a config structure
      client = EndpointBindings::Client.new(bar: 'config_bar', endpoint: 'config_endpoint', boolean_param: false)
      config = client.config
      parameters = EndpointBindings::EndpointParameters.create(config)
      expect(parameters.baz).to eq('baz')
      expect(parameters.endpoint).to eq('config_endpoint')
      expect(parameters.bar).to eq('config_bar')
      expect(parameters.boolean_param).to eq(false)
    end
  end
end
