# frozen_string_literal: true

module Smithy
  module Client
    describe Plugin do
      let(:handlers) { HandlerList.new }
      let(:config) { Configuration.new }
      let(:plugin) { Class.new(Plugin) }

      it 'is a HandlerBuilder' do
        expect(plugin).to be_kind_of(HandlerBuilder)
      end

      describe '#add_options' do
        it 'adds options registered by .option' do
          plugin.option(:opt_without_default)
          plugin.option(:opt_with_default, default: 'DEFAULT')
          plugin.option(:opt_with_block) { 'BLOCK-DEFAULT' }
          plugin.new.add_options(config)
          cfg = config.build!
          expect(cfg.opt_without_default).to eq(nil)
          expect(cfg.opt_with_default).to eq('DEFAULT')
          expect(cfg.opt_with_block).to eq('BLOCK-DEFAULT')
        end
      end

      describe '#add_handlers' do
        it 'does nothing by default' do
          plugin.new.add_handlers(handlers, config.build!)
        end

        it 'adds handlers registered by .handler' do
          build_handler = Class.new
          sign_handler = Class.new
          send_handler = Class.new
          plugin.handler(build_handler)
          plugin.handler(sign_handler, step: :sign)
          plugin.handler(send_handler, step: :send)
          plugin.new.add_handlers(handlers, config.build!)
          expect(handlers.to_a).to eq([send_handler, sign_handler, build_handler])
        end
      end

      describe '#before_initialize' do
        it 'calls before_initialize hooks' do
          client_class = Class.new(Base)
          plugin = Class.new(Plugin) do
            option(:foo)
            option(:endpoint, default: 'https://example.com')
            option(:yielded_class)
            option(:yielded_options)

            def before_initialize(klass, options)
              options[:yielded_options] = options.dup
              options[:yielded_class] = klass
            end
          end
          client_class.add_plugin(plugin)
          client = client_class.new(foo: 'bar')
          expect(client.config.yielded_options).to include(foo: 'bar')
          expect(client.config.yielded_class).to be(client.class)
        end
      end

      describe '#after_initialize' do
        it 'calls after_initialize hooks' do
          client_class = Class.new(Base)
          plugin = Class.new(Plugin) do
            option(:endpoint, default: 'https://example.com')
            option(:initialized_client)

            def after_initialize(client)
              client.config.initialized_client = client
            end
          end
          client_class.add_plugin(plugin)
          client = client_class.new
          expect(client.config.initialized_client).to be(client)
        end
      end

      describe '.option' do
        it 'provides a short-cut method for adding options' do
          plugin = Class.new(Plugin) { option(:opt) }
          plugin.new.add_options(config)
          expect(config.build!.opt).to be(nil)
        end

        it 'accepts a static default value' do
          plugin = Class.new(Plugin) { option(:opt, default: 'default') }
          plugin.new.add_options(config)
          expect(config.build!.opt).to eq('default')
        end

        it 'accepts a default value as a block' do
          value = Object.new
          plugin = Class.new(Plugin) do
            option(:opt) { value }
          end
          plugin.new.add_options(config)
          expect(config.build!.opt).to be(value)
        end

        it 'accepts a default block value and yields the config' do
          plugin = Class.new(Plugin) do
            option(:opt1, default: 10)
            option(:opt2) { |config| config.opt1 * 2 }
          end
          plugin.new.add_options(config)
          expect(config.build!.opt2).to equal(20)
        end
      end

      describe '.before_initialize' do
        it 'yields the client class and constructor options to the plugin' do
          yielded_class = nil
          yielded_options = nil
          client_class = Class.new(Base)
          plugin = Class.new(Plugin) do
            option(:foo)
            option(:endpoint, default: 'https://example.com')
            before_initialize do |klass, options|
              yielded_class = klass
              yielded_options = options
            end
          end
          client_class.add_plugin(plugin)
          client = client_class.new(foo: 'bar')
          expect(yielded_class).to be(client.class)
          expect(yielded_options).to include(foo: 'bar')
          expect(client.config.foo).to eq('bar')
        end
      end

      describe '.after_initialize' do
        it 'yields the fully constructed client to the plugin' do
          initialized_client = nil
          client_class = Class.new(Base)
          plugin = Class.new(Plugin) do
            option(:endpoint, default: 'https://example.com')
            after_initialize { |c| initialized_client = c }
          end
          client_class.add_plugin(plugin)
          client = client_class.new
          expect(client).to be(initialized_client)
        end
      end
    end
  end
end
