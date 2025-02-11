# frozen_string_literal: true

describe 'Client: EndpointParameters', rbs_test: true do
  ['generated client gem', 'generated client from source code'].each do |context|
    next if ENV['SMITHY_RUBY_RBS_TEST'] && context != 'generated client gem'

    context context do
      include_context context, fixture: 'endpoints/endpoint-bindings', module_name: 'EndpointBindings'

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
          client = EndpointBindings::Client.new(bar: 'config_bar', endpoint: 'config_endpoint', boolean_param: false)
          client.config
        end

        context 'no_bindings_operation' do
          it 'creates with default values and values from config' do
            context = double(config: config, operation_name: :no_bindings_operation, params: {})
            parameters = EndpointBindings::EndpointParameters.create(context)
            expect(parameters.baz).to eq('baz')
            expect(parameters.endpoint).to eq('config_endpoint')
            expect(parameters.bar).to eq('config_bar')
            expect(parameters.boolean_param).to eq(false)
          end
        end

        context 'static_context_operation' do
          it 'creates with values from StaticContextParams' do
            context = double(config: config, operation_name: :static_context_operation, params: {})
            parameters = EndpointBindings::EndpointParameters.create(context)
            expect(parameters.bar).to eq('static-context')
          end
        end

        context 'context_params_operation' do
          it 'creates with values from operation params' do
            params =  { bar: 'operation-bar' }
            context = double(config: config, operation_name: :context_params_operation, params: params)
            parameters = EndpointBindings::EndpointParameters.create(context)
            expect(parameters.bar).to eq('operation-bar')
          end
        end

        context 'operation_context_params_operation' do
          it 'creates with values from operation params' do
            params = {
              nested: { bar: 'nested-bar', baz: 'nested-baz' },
              boolean_param: false
            }
            context = double(config: config, operation_name: :operation_context_params_operation, params: params)

            parameters = EndpointBindings::EndpointParameters.create(context)
            expect(parameters.bar).to eq('nested-bar')
            expect(parameters.baz).to eq('nested-baz')
            expect(parameters.boolean_param).to eq(false)
          end
        end
      end
    end
  end
end
