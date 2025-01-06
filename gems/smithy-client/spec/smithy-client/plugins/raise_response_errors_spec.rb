# frozen_string_literal: true

module Smithy
  module Client
    module Plugins
      describe RaiseResponseErrors do
        let(:client_class) do
          schema = Schema.new
          schema.add_operation(:operation_name, Shapes::OperationShape.new)
          client_class = Class.new(Client::Base)
          client_class.schema = schema
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
          expect(client.handlers).not_to include(Handler)
        end

        it 'returns output' do
          client = client_class.new
          output = client.operation_name
          expect(output).to be_kind_of(Output)
        end

        it 'raises the response error when :raise_response_errors is true' do
          error = StandardError.new('msg')
          client = client_class.new(response_error: error)
          expect { client.operation_name }.to raise_error(error)
        end

        it 'puts the error on the output when :raise_response_errors is false' do
          error = StandardError.new('msg')
          client = client_class.new(
            raise_response_errors: false,
            response_error: error
          )
          output = client.operation_name
          expect(output.error).to be(error)
        end
      end
    end
  end
end
