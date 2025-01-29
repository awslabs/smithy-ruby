# frozen_string_literal: true

module Smithy
  module Client
    class TestUnion < Union
      class StringValue < TestUnion
        def to_h
          { string_value: super(__getobj__) }
        end
      end
    end

    describe Union do
      subject { TestUnion::StringValue.new('union') }

      it 'uses simple delegator and structure' do
        expect(subject).to be_a(SimpleDelegator)
        expect(subject).to be_a(Structure)
      end

      describe '#to_h' do
        it 'serializes the value to a hash' do
          expect(subject.to_h).to eq(string_value: 'union')
        end
      end

      describe '#to_s' do
        it 'returns a string representation' do
          expect(subject.to_s)
            .to eq('#<Smithy::Client::TestUnion::StringValue union>')
        end
      end
    end
  end
end
