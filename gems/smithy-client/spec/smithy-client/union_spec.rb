# frozen_string_literal: true

module Smithy
  module Client
    describe Union do
      let(:test_union_class) { Class.new(Union) }
      let(:string_value_class) do
        Class.new(test_union_class) do
          def to_h
            { string_value: super(__getobj__) }
          end

          # anonymous class, need a class name to test to_s
          def self.name
            'TestUnion::StringValue'
          end
        end
      end

      subject { string_value_class.new('union') }

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
            .to eq('#<TestUnion::StringValue union>')
        end
      end
    end
  end
end
