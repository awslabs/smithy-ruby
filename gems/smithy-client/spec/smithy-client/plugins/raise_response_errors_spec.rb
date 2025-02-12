# frozen_string_literal: true

require 'smithy-client/plugins/raise_response_errors'

module Smithy
  module Client
    module Plugins
      describe RaiseResponseErrors do
        let(:client_class) do
          client_class = ClientHelper.sample_service.const_get(:Client)
          client_class.clear_plugins
          client_class.add_plugin(RaiseResponseErrors)
          client_class.add_plugin(DummySendPlugin)
          client_class
        end

        it 'adds a :raise_response_errors option to config' do
          client = client_class.new(raise_response_errors: false)
          expect(client.config.raise_response_errors).to be(false)
        end

        it 'defaults :raise_response_errors to true' do
          client = client_class.new
          expect(client.config.raise_response_errors).to be(true)
        end

        it 'does not add the handler if :raise_response_errors is false' do
          client = client_class.new(raise_response_errors: false)
          expect(client.handlers).not_to include(RaiseResponseErrors::Handler)
        end

        it 'adds the handler if :raise_response_errors is true' do
          client = client_class.new(raise_response_errors: true)
          expect(client.handlers).to include(RaiseResponseErrors::Handler)
        end

        it 'returns output' do
          client = client_class.new
          output = client.operation
          expect(output).to be_kind_of(Output)
        end

        it 'raises the response error when :raise_response_errors is true' do
          error = StandardError.new('msg')
          client = client_class.new(response_error: error)
          expect { client.operation }.to raise_error(error)
        end

        it 'puts the error on the output when :raise_response_errors is false' do
          error = StandardError.new('msg')
          client = client_class.new(
            raise_response_errors: false,
            response_error: error
          )
          output = client.operation
          expect(output.error).to be(error)
        end
      end
    end
  end
end
