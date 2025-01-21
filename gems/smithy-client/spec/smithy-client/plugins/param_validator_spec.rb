# frozen_string_literal: true

module Smithy
  module Client
    module Plugins
      describe ParamValidator do
        let(:input) do
          shape = Shapes::StructureShape.new
          shape.add_member(:foo, Shapes::StringShape.new)
          shape
        end
        let(:operation_shape) { Shapes::OperationShape.new(input: input) }

        let(:client_class) do
          schema = Schema.new
          schema.add_operation(:operation_name, operation_shape)
          client_class = Class.new(Client::Base)
          client_class.schema = schema
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

        it 'validates params' do
          client = client_class.new
          params = { foo: 'bar' }
          expect(Client::ParamValidator).to receive(:validate!).with(input, params)
          client.operation_name(params)
        end
      end
    end
  end
end
