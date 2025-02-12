# frozen_string_literal: true

require 'smithy-client/plugins/param_converter'

module Smithy
  module Client
    module Plugins
      describe ParamConverter do
        let(:sample_service) { ClientHelper.sample_service }

        let(:client_class) do
          client_class = sample_service.const_get(:Client)
          client_class.clear_plugins
          client_class.add_plugin(ParamConverter)
          client_class.add_plugin(DummySendPlugin)
          client_class
        end

        it 'adds a :convert_params option to config' do
          client = client_class.new(convert_params: false)
          expect(client.config.convert_params).to be(false)
        end

        it 'defaults :convert_params to true' do
          client = client_class.new
          expect(client.config.convert_params).to be(true)
        end

        it 'does not add the handler unless :convert_params is true' do
          client = client_class.new(convert_params: false)
          expect(client.handlers).not_to include(ParamConverter::Handler)
        end

        it 'adds the handler when :convert_params is true' do
          client = client_class.new(convert_params: true)
          expect(client.handlers).to include(ParamConverter::Handler)
        end

        it 'calls the param converter' do
          client = client_class.new
          params = {}
          input = sample_service.const_get(:Shapes).const_get(:SCHEMA).operation(:operation).input
          expect(Client::ParamConverter).to receive(:new).with(input).and_call_original
          expect_any_instance_of(Client::ParamConverter).to receive(:convert).with(params).and_call_original
          client.operation(params)
        end

        it 'closes files opened by the param converter' do
          client = client_class.new
          params = {}
          expect_any_instance_of(Client::ParamConverter).to receive(:close_opened_files)
          client.operation(params)
        end
      end
    end
  end
end
