# frozen_string_literal: true

module Smithy
  module Client
    describe HandlerList, rbs_test: :skip do
      subject { HandlerList.new }

      it 'is enumerable' do
        expect(subject).to be_kind_of(Enumerable)
      end

      describe '#each' do
        it 'yields the handlers in stack order' do
          handler1 = Handler.new
          handler2 = Handler.new
          handler3 = Handler.new
          subject.add(handler1)
          subject.add(handler2)
          subject.add(handler3)
          expect { |b| subject.each(&b) }.to yield_successive_args(handler3, handler2, handler1)
        end
      end

      describe '#entries' do
        it 'returns an array of handler entries' do
          handler1 = Handler.new
          handler2 = Handler.new
          handler3 = Handler.new
          subject.add(handler1)
          subject.add(handler2)
          subject.add(handler3)
          expect(subject.entries.map(&:handler_class)).to eq([handler1, handler2, handler3])
        end
      end

      describe '#add' do
        it 'adds a handler' do
          handler = Handler.new
          subject.add(handler)
          expect(subject.to_a).to eq([handler])
        end

        it 'handlers added first have a higher priority' do
          handler1 = Handler.new
          handler2 = Handler.new
          subject.add(handler1)
          subject.add(handler2)
          expect(subject.to_a).to eq([handler2, handler1])
        end

        it 'returns the handler class' do
          handler_class = Class.new(Handler)
          expect(subject.add(handler_class)).to be(handler_class)
        end

        context ':step' do
          it 'sorts handlers by step priority order' do
            subject.add('validate', step: :validate)
            subject.add('build', step: :build)
            subject.add('sign', step: :sign)
            subject.add('send', step: :send)
            expect(subject.to_a).to eq(%w[send sign build validate])
          end

          it 'defaults step to :build' do
            subject.add('validate', step: :validate)
            subject.add('build')
            subject.add('sign', step: :sign)
            expect(subject.to_a).to eq(%w[sign build validate])
          end

          it 'accepts multiple handlers with the same step' do
            subject.add('h1', step: :validate)
            subject.add('h2', step: :validate)
            subject.add('h3', step: :build)
            subject.add('h4', step: :build)
            expect(subject.to_a).to eq(%w[h4 h3 h2 h1])
          end
        end

        context ':priority' do
          it 'accepts a priority' do
            subject.add('medium', priority: 50)
            subject.add('high', priority: 80)
            subject.add('low', priority: 20)
            expect(subject.to_a).to eq(%w[low medium high])
          end

          it 'sorts handler with the same priority in FIFO order' do
            subject.add('a', priority: 20, step: :sign)
            subject.add('b', priority: 20, step: :sign)
            subject.add('c', priority: 20, step: :sign)
            subject.add('m', priority: 20, step: :build)
            subject.add('n', priority: 20, step: :build)
            subject.add('o', priority: 20, step: :build)
            subject.add('x', priority: 20, step: :validate)
            subject.add('y', priority: 20, step: :validate)
            subject.add('z', priority: 20, step: :validate)
            subject.add('-', step: :send)
            expect(subject.to_a).to eq(%w[- c b a o n m z y x])
          end
        end

        context 'errors' do
          it 'raises an error if :step is not valid' do
            msg = 'invalid :step `:bogus\', must be one of :initialize, ' \
                  ':validate, :build, :sign or :send'
            expect do
              subject.add('handler', step: :bogus)
            end.to raise_error(ArgumentError, msg)
          end

          it 'raises an error if :priority is less than 0' do
            msg = 'invalid :priority `-1\', must be between 0 and 99'
            expect do
              subject.add('handler', priority: -1)
            end.to raise_error(ArgumentError, msg)
          end

          it 'raises an error if :priority is greater than 99' do
            msg = 'invalid :priority `100\', must be between 0 and 99'
            expect do
              subject.add('handler', priority: 100)
            end.to raise_error(ArgumentError, msg)
          end
        end

        context ':step => :send' do
          it 'only keeps the latest send handler' do
            subject.add('handler1', step: :send)
            subject.add('handler2', step: :send)
            subject.add('handler3', step: :send)
            expect(subject.to_a).to eq(['handler3'])
          end

          it 'ignores :priority when adding :send handlers' do
            subject.add('handler1', step: :send, priority: 80)
            subject.add('handler2', step: :send, priority: 50)
            subject.add('handler3', step: :send, priority: 20)
            expect(subject.to_a).to eq(['handler3'])
          end
        end

        context ':operations' do
          it 'adds a handler that is not enumerated by default' do
            subject.add('handler', operations: [:operation_name])
            expect(subject.to_a).to eq([])
          end

          it 'adds a handler that is enumerated for a given :operation' do
            subject.add('handler1', operations: [:operation1])
            subject.add('handler2', operations: [:operation1])
            subject.add('handler3', operations: [:operation2])
            expect(subject.for(:operation1).to_a).to eq(%w[handler2 handler1])
          end

          it 'does not add handlers when operation list is empty' do
            subject.add('handler1', operations: [:operation1])
            subject.add('handler2', operations: [])
            expect(subject.for(:operation1).to_a).to eq(%w[handler1])
          end

          it 'does add handlers when operation list is nil' do
            subject.add('handler1', operations: [:operation1])
            subject.add('handler2', operations: nil)
            expect(subject.for(:operation1).to_a).to eq(%w[handler2 handler1])
          end
        end
      end

      describe '#remove' do
        it 'removes a handler entry' do
          subject.add('handler')
          subject.remove('handler')
          expect(subject.to_a).to eq([])
        end

        it 'ignores entries that do not match the handler class' do
          subject.add('handler')
          subject.remove('unknown')
          expect(subject.to_a).to eq(['handler'])
        end
      end

      describe '#copy_from' do
        it 'copies handlers from one list to another' do
          subject.add('send', step: :send)
          subject.add('handler')
          handlers2 = HandlerList.new
          handlers2.copy_from(subject)
          expect(handlers2.to_a).to eq(subject.to_a)
        end

        it 'accepts a block to skip handlers when the block returns false' do
          subject.add('handler1')
          subject.add('handler2')
          filtered = HandlerList.new
          filtered.copy_from(subject) do |entry|
            entry.handler_class != 'handler1'
          end
          expect(filtered.to_a).to eq(['handler2'])
        end
      end

      describe '#for' do
        it 'returns a handler list' do
          expect(subject.for(:operation)).to be_kind_of(HandlerList)
        end

        it 'returns a different handler list' do
          expect(subject.for(:operation)).to_not be(subject)
        end

        it 'copies the send handler' do
          subject.add('send', step: :send)
          expect(subject.for(:operation).to_a).to eq(['send'])
        end

        it 'copies the common handlers' do
          subject.add('validate', step: :validate)
          subject.add('build', step: :build)
          subject.add('sign', step: :sign)
          expect(subject.for('operation').to_a).to eq(%w[sign build validate])
        end

        it 'deep copies handlers' do
          subject.add('handler1')
          handlers2 = subject.for('operation')
          handlers2.add('handler2')
          expect(subject.to_a).to eq(['handler1'])
          expect(handlers2.to_a).to eq(%w[handler2 handler1])
        end

        it 'copies operation handlers with the given name' do
          subject.add('handler', operations: [:operation])
          expect(subject.for(:operation).to_a).to eq(['handler'])
        end

        it 'does not copy operation handlers that have a different name' do
          subject.add('handler', operations: ['operation'])
          expect(subject.for(:operation2).to_a).to eq([])
        end

        it 'merges operation and common handlers preserving priority' do
          subject.add('high', priority: 30, operation: :operation)
          subject.add('medium', priority: 20, operation: :operation)
          subject.add('low', priority: 10)
          expect(subject.for(:operation).to_a).to eq(%w[low medium high])
        end
      end

      describe '#to_stack' do
        it 'constructs a handler stack' do
          handler = Handler
          expect(handler).to receive(:new).with(nil).and_return(1)
          expect(handler).to receive(:new).with(1).and_return(2)
          expect(handler).to receive(:new).with(2).and_return(3)
          subject.add(handler)
          subject.add(handler)
          subject.add(handler)
          expect(subject.to_stack).to eq(3)
        end
      end
    end
  end
end
