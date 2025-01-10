# frozen_string_literal: true

module Smithy
  describe Plan do
    let(:fixture) { File.expand_path('../fixtures/weather/model.json', __dir__.to_s) }
    let(:model) { JSON.load_file(fixture) }
    let(:type) { :client }
    let(:options) { {} }

    subject { described_class.new(model, type, options) }

    describe '#model' do
      it 'returns the model' do
        expect(subject.model).to eq(model)
      end
    end

    describe '#type' do
      it 'returns the type' do
        expect(subject.type).to eq(type)
      end
    end

    describe '#options' do
      it 'returns the options' do
        expect(subject.options).to eq(options)
      end
    end

    describe '#rivets' do
      it 'returns the rivets' do
        expect(subject.rivets).to eq(Rivets.for(subject.service))
      end
    end

    describe '#service' do
      context 'one service shape' do
        let(:fixture) { File.expand_path('../fixtures/one_service/model.json', __dir__.to_s) }

        it 'finds the service shape' do
          expected = model['shapes'].select { |_, shape| shape['type'] == 'service' }
          actual = subject.service
          expect(actual.keys.first).to eq(expected.keys.first)
        end
      end

      context 'no service shapes' do
        let(:fixture) { File.expand_path('../fixtures/no_service/model.json', __dir__.to_s) }

        it 'raises an error' do
          expect { subject }.to raise_error('No service shape found')
        end
      end

      context 'multiple service shapes' do
        let(:fixture) { File.expand_path('../fixtures/multi_service/model.json', __dir__.to_s) }

        it 'raises an error' do
          expect { subject }.to raise_error('Multiple service shapes found')
        end
      end
    end
  end
end
