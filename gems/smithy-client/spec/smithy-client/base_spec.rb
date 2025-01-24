# frozen_string_literal: true

module Smithy
  module Client
    describe Base do
      let(:schema) { Schema.new }
      let(:client_class) { Base.define(schema: schema) }
      let(:plugin_a) { Plugin.new }
      let(:plugin_b) { Plugin.new }

      subject { client_class.new }

      it 'is a HandlerBuilder' do
        expect(subject).to be_kind_of(HandlerBuilder)
      end

      describe '#config' do
        it 'returns a Configuration struct' do
          expect(subject.config).to be_kind_of(Struct)
        end

        it 'contains a schema' do
          expect(subject.config.schema).to be(client_class.schema)
        end

        it 'passes constructor args to the config' do
          expect do
            client_class.new(foo: 'bar')
          end.to raise_error(ArgumentError, /invalid configuration option/)
        end
      end

      describe '#handlers' do
        it 'returns a HandlerList' do
          expect(subject.handlers).to be_kind_of(HandlerList)
        end

        it 'builds a handler list from client plugins' do
          client_class.clear_plugins
          client_class.add_plugin(DummySendPlugin)
          expect(client_class.new.handlers).to include(DummySendPlugin::Handler)
        end
      end

      describe '#build_input' do
        let(:input) { subject.build_input(:operation) }

        before(:each) do
          schema.add_operation(:operation, Shapes::OperationShape.new)
        end

        it 'returns an Input' do
          expect(input).to be_kind_of(Input)
        end

        it 'populates the handlers' do
          expect(input.handlers.to_a).to eq(subject.handlers.to_a)
        end

        it 'includes operation specific handlers in the handler list' do
          subject.handler(Handler, operations: [:operation])
          input = subject.build_input(:operation)
          expect(input.handlers.to_a).to include(Handler)
        end

        it 'populates the handler context operation name' do
          input = subject.build_input(:operation)
          expect(input.context.operation_name).to eq(:operation)
        end

        it 'defaults params to an empty hash' do
          input = subject.build_input(:operation)
          expect(input.context.params).to eq({})
        end

        it 'populates the handler context params' do
          params = {}
          input = subject.build_input(:operation, params)
          expect(input.context.params).to be(params)
        end

        it 'populates the handler context configuration' do
          input = subject.build_input(:operation)
          expect(input.context.config).to be(subject.config)
        end

        it 'raises an error for unknown operations' do
          expect do
            subject.build_input(:foo)
          end.to raise_error('unknown operation :foo')
        end
      end

      describe '#inspect' do
        it 'returns the class name' do
          expect(subject.inspect).to eq('#<Smithy::Client::Base>')
        end
      end

      context 'api operations' do
        let(:input) { Input.new }

        before(:each) do
          schema.add_operation(:operation, Shapes::OperationShape.new)
          allow(subject).to receive(:build_input).and_return(input)
          allow(input).to receive(:send_request)
        end

        it 'can return a list of valid operation names' do
          expect(subject.operation_names).to eq([:operation])
        end

        it 'responds to each operation name' do
          subject.operation_names.each do |operation_name|
            expect(subject).to respond_to(operation_name)
          end
        end

        it 'builds and sends a request when it receives a request method' do
          expect(subject).to receive(:build_input)
            .with(:operation, { foo: 'bar' })
            .and_return(input)
          expect(input).to receive(:send_request)
          subject.operation(foo: 'bar')
        end

        it 'passes block arguments to the request method' do
          allow(input).to receive(:send_request)
            .and_yield('chunk1')
            .and_yield('chunk2')
            .and_yield('chunk3')
          chunks = []
          subject.operation(foo: 'bar') do |chunk|
            chunks << chunk
          end
          expect(chunks).to eq(%w[chunk1 chunk2 chunk3])
        end
      end

      describe '.new' do
        context 'class level plugin' do
          it 'instructs plugins to #before_initialize' do
            options = {}
            expect(plugin_a).to receive(:before_initialize)
              .with(client_class, hash_including(options))
            client_class.add_plugin(plugin_a)
            client_class.new(options)
          end

          it 'instructs plugins to #add_options' do
            expect(plugin_a).to receive(:add_options) do |config|
              config.add_option(:foo, 'bar')
              config.add_option(:endpoint, 'https://example.com')
            end
            client_class.add_plugin(plugin_a)
            expect(client_class.new.config.foo).to eq('bar')
          end

          it 'instructs plugins to #add_handlers' do
            expect(plugin_a).to receive(:add_handlers)
              .with(kind_of(HandlerList), kind_of(Struct))
            client_class.add_plugin(plugin_a)
            client_class.new
          end

          it 'instructs plugins to #after_initialize' do
            expect(plugin_a).to receive(:after_initialize).with(kind_of(Base))
            client_class.add_plugin(plugin_a)
            client_class.new
          end

          it 'does not call methods that plugin does not respond to' do
            plugin = Object.new
            client_class.add_plugin(plugin)
            client_class.new
          end
        end
      end

      describe '.add_plugin' do
        it 'adds plugins to the client' do
          client_class.add_plugin(plugin_a)
          expect(client_class.plugins).to include(plugin_a)
        end

        it 'does not add plugins to the client parent class' do
          subclass = Class.new(client_class)
          subclass.add_plugin(plugin_a)
          expect(client_class.plugins).to_not include(plugin_a)
          expect(subclass.plugins).to include(plugin_a)
        end
      end

      describe '.remove_plugin' do
        it 'removes a plugin from the client' do
          client_class.add_plugin(plugin_a)
          client_class.add_plugin(plugin_b)
          client_class.remove_plugin(plugin_a)
          expect(client_class.plugins).not_to include(plugin_a)
          expect(client_class.plugins).to include(plugin_b)
        end

        it 'does not remove plugins from the client parent class' do
          client_class.add_plugin(plugin_a)
          subclass = client_class.define
          subclass.remove_plugin(plugin_a)
          expect(client_class.plugins).to include(plugin_a)
          expect(subclass.plugins).not_to include(plugin_a)
        end
      end

      describe '.clear_plugins' do
        it 'removes all plugins' do
          client_class.add_plugin(plugin_a)
          client_class.clear_plugins
          expect(client_class.plugins).to eq([])
        end
      end

      describe '.plugins=' do
        it 'replaces existing plugins' do
          client_class.add_plugin(plugin_a)
          client_class.plugins = [plugin_b]
          expect(client_class.plugins).to eq([plugin_b])
        end
      end

      describe '.plugins' do
        it 'returns a list of plugins applied to the client' do
          expect(client_class.plugins).to be_kind_of(Array)
        end

        it 'returns a frozen list of plugins' do
          expect(client_class.plugins.frozen?).to eq(true)
        end

        it 'has a default list of plugins' do
          client_class = Class.new(Base)
          expected = [
            Plugins::Logging,
            Plugins::RaiseResponseErrors,
            Plugins::ResponseTarget
          ]
          expect(client_class.plugins.to_a).to eq(expected)
        end
      end

      describe '.schema' do
        it 'defaults to a Schema' do
          expect(client_class.schema).to be_kind_of(Schema)
        end
      end

      describe '.schema=' do
        it 'can be set' do
          schema = Schema.new
          client_class.schema = schema
          expect(client_class.schema).to be(schema)
        end
      end

      describe '.define' do
        it 'creates a new client class' do
          client_class = Base.define
          expect(client_class.ancestors).to include(Client::Base)
        end

        it 'sets the schema on the client class' do
          schema = Schema.new
          client_class = Base.define(schema: schema)
          expect(client_class.schema).to be(schema)
        end

        it 'extends from subclasses of client' do
          klass1 = Base.define
          klass2 = klass1.define
          expect(klass2.ancestors).to include(klass1)
          expect(klass2.ancestors).to include(Client::Base)
        end

        it 'applies plugins passed in via :plugins' do
          client_class = Base.define(plugins: [plugin_a])
          expect(client_class.plugins).to include(plugin_a)
        end
      end
    end
  end
end
