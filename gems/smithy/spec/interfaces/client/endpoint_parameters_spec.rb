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
    let(:config) do
      # need to get a config structure
      client = EndpointBindings::Client.new(bar: 'config_bar', endpoint: 'config_endpoint', boolean_param: false)
      client.config
    end

    context 'no_bindings_operation' do
      it 'creates with default values and values from config' do
        parameters = EndpointBindings::EndpointParameters.create(config, :no_bindings_operation, {})
        expect(parameters.baz).to eq('baz')
        expect(parameters.endpoint).to eq('config_endpoint')
        expect(parameters.bar).to eq('config_bar')
        expect(parameters.boolean_param).to eq(false)
      end
    end

    context 'static_context_operation' do
      it 'creates with values from StaticContextParams' do
        parameters = EndpointBindings::EndpointParameters.create(config, :static_context_operation, {})
        expect(parameters.bar).to eq('static-context')
      end
    end

    context 'context_params_operation' do
      it 'creates with values from operation params' do
        parameters = EndpointBindings::EndpointParameters.create(
          config, :context_params_operation, { bar: 'operation-bar' }
        )
        expect(parameters.bar).to eq('operation-bar')
      end
    end

    context 'operation_context_params_operation' do
      it 'creates with values from operation params' do
        params = {
          nested: { bar: 'nested-bar', baz: 'nested-baz' },
          boolean_param: false
        }
        parameters = EndpointBindings::EndpointParameters.create(
          config, :operation_context_params_operation, params
        )
        expect(parameters.bar).to eq('nested-bar')
        expect(parameters.baz).to eq('nested-baz')
        expect(parameters.boolean_param).to eq(false)
      end
    end
  end
end
