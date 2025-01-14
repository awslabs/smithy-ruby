# frozen_string_literal: true

module Smithy
  module Client
    describe HandlerBuilder do
      let(:klass) do
        Class.new do
          include HandlerBuilder

          def initialize
            @handlers = HandlerList.new
          end

          attr_reader :handlers
        end
      end

      subject { klass.new }

      describe '#handler' do
        it 'registers a handler' do
          handler_class = Class.new(Handler)
          subject.handler(handler_class)
          expect(subject.handlers).to include(handler_class)
        end

        it 'accepts a step option' do
          handler1 = Class.new(Handler)
          handler2 = Class.new(Handler)
          subject.handler(handler1, step: :validate)
          subject.handler(handler2, step: :build)
          expect(subject.handlers).to include(handler1)
          expect(subject.handlers).to include(handler2)
        end

        it 'builds a handler from a block' do
          handler_class = subject.handler do |context|
            context
          end
          expect(handler_class.ancestors).to include(Handler)
          expect(handler_class.new.call('context')).to eq('context')
        end

        it 'accepts a step with the block', rbs_test: :skip do
          subject.handler(step: :validate) do |context|
            context << :validate
            super(context)
          end
          subject.handler(step: :build) do |context|
            context << :build
            @handler.call(context)
          end
          subject.handler(step: :sign) do |context|
            context << :sign
            handler.call(context)
          end
          subject.handler(step: :send) do |context|
            context << :send
            context
          end
          resp = subject.handlers.to_stack.call([])
          expect(resp).to eq(%i[validate build sign send])
        end

        it 'returns the handler class' do
          handler_class = Class.new(Handler)
          expect(subject.handler(handler_class)).to be(handler_class)
        end
      end

      describe 'naming handlers inside modules' do
        let(:mod) do
          Module.new do
            extend HandlerBuilder

            def self.handlers
              @handlers ||= HandlerList.new
            end
          end
        end

        it 'assigns the handler to a constant if a name is given' do
          expect(mod.const_defined?('MyHandler')).to be(false)
          handler_class = mod.handler('MyHandler') { |_arg| } # empty
          expect(mod::MyHandler).to be(handler_class)
        end

        it 'accepts the handler name as a symbol' do
          handler_class = mod.handler(:MyHandler) { |_arg| } # empty
          expect(mod::MyHandler).to be(handler_class)
        end

        it 'accepts a name and options at the same time' do
          mod.handler(:FirstSendHandler, step: :send) { |_arg| } # empty
          mod.handler(:SecondSendHandler, step: :send) { |_arg| } # empty
          expect(mod.handlers).not_to include(mod::FirstSendHandler)
          expect(mod.handlers).to include(mod::SecondSendHandler)
        end
      end
    end
  end
end
