# frozen_string_literal: true

module Smithy
  module Client
    describe Output do
      subject { Output.new }

      it 'is a Delegator' do
        expect(subject).to be_kind_of(Delegator)
      end

      it 'delegates to the data with a getter' do
        data = double('data')
        subject.data = data
        expect(subject.__getobj__).to be(data)
      end

      it 'delegates to the data with a setter' do
        data = double('data')
        subject.__setobj__(data)
        expect(subject.data).to be(data)
      end

      describe '#initialize' do
        it 'defaults the context to a new HandlerContext' do
          expect(Output.new.context).to be_kind_of(HandlerContext)
        end
      end

      describe '#data' do
        it 'returns the data' do
          data = double('data')
          subject.data = data
          expect(subject.data).to be(data)
        end
      end

      describe '#error' do
        it 'returns the error' do
          error = StandardError.new
          subject.error = error
          expect(subject.error).to be(error)
        end
      end

      describe '#context' do
        it 'returns the context' do
          context = HandlerContext.new
          output = Output.new(context: context)
          expect(output.context).to be(context)
        end
      end
    end
  end
end
