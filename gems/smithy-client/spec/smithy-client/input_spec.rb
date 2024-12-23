# frozen_string_literal: true

require 'tempfile'

module Smithy
  module Client
    describe Input do
      let(:handlers) { HandlerList.new }
      let(:context) { HandlerContext.new }

      subject { Input.new(handlers: handlers, context: context) }

      it 'is a HandlerBuilder' do
        expect(subject).to be_kind_of(HandlerBuilder)
      end

      describe '#initialize' do
        it 'defaults handlers to an empty HandlerList' do
          expect(Input.new.handlers).to be_kind_of(HandlerList)
        end

        it 'defaults context to a new HandlerContext' do
          expect(Input.new.context).to be_kind_of(HandlerContext)
        end
      end

      describe '#handlers' do
        it 'returns the handler list' do
          expect(subject.handlers).to be(handlers)
        end
      end

      describe '#context' do
        it 'returns the context' do
          expect(subject.context).to be(context)
        end
      end

      describe '#send_request' do
        it 'constructs a stack from the handler list' do
          expect(handlers).to receive(:to_stack).and_return(->(context) {})
          subject.send_request
        end

        it 'returns the output from the handler stack #call method' do
          output = double('output')
          allow(handlers).to receive(:to_stack).and_return(->(_) { output })
          expect(subject.send_request).to be(output)
        end

        it 'passes the handler context to the handler stack' do
          passed = nil
          allow(handlers).to receive(:to_stack)
            .and_return(->(context) { passed = context })
          subject.send_request
          expect(passed).to be(context)
        end

        context 'response target' do
          it 'TODO'
        end
      end
    end
  end
end
