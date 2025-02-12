# frozen_string_literal: true

require 'smithy-client/plugins/param_validator'

module Smithy
  module Client
    module Plugins
      describe ParamValidator do
        let(:sample_service) { ClientHelper.sample_service }

        let(:client_class) do
          client_class = sample_service.const_get(:Client)
          client_class.clear_plugins
          client_class.add_plugin(ParamValidator)
          client_class.add_plugin(DummySendPlugin)
          client_class
        end

        it 'adds a :validate_params option to config' do
          client = client_class.new(validate_params: false)
          expect(client.config.validate_params).to be(false)
        end

        it 'defaults :validate_params to true' do
          client = client_class.new
          expect(client.config.validate_params).to be(true)
        end

        it 'does not add the handler unless :validate_params is true' do
          client = client_class.new(validate_params: false)
          expect(client.handlers).not_to include(ParamValidator::Handler)
        end

        it 'adds the handler when :validate_params is true' do
          client = client_class.new(validate_params: true)
          expect(client.handlers).to include(ParamValidator::Handler)
        end

        it 'calls the param validator' do
          client = client_class.new
          params = {}
          input = sample_service.const_get(:Shapes).const_get(:SCHEMA).operation(:operation).input
          expect(Client::ParamValidator).to receive(:new).with(input).and_call_original
          expect_any_instance_of(Client::ParamValidator).to receive(:validate!).with(params).and_call_original
          client.operation(params)
        end
      end
    end
  end
end
