# frozen_string_literal: true

module Smithy
  module Vise
    describe ServiceIndex do
      let(:model) { JSON.load_file(fixture) }

      subject { described_class.new(model) }

      describe '#service' do
        context 'one service shape' do
          let(:fixture) { File.expand_path('../../fixtures/vise/model.json', __dir__) }

          it 'finds the service shape' do
            expected = model['shapes'].select { |_, shape| shape['type'] == 'service' }
            actual = subject.service
            expect(actual.keys.first).to eq(expected.keys.first)
          end
        end

        context 'no service shapes' do
          let(:fixture) { File.expand_path('../../fixtures/vise_no_service/model.json', __dir__) }

          it 'raises an error' do
            expect { subject.service }.to raise_error('No service shape found')
          end
        end

        context 'multiple service shapes' do
          let(:fixture) { File.expand_path('../../fixtures/vise_multi_service/model.json', __dir__) }

          it 'raises an error' do
            expect { subject.service }.to raise_error('Multiple service shapes found')
          end
        end
      end
    end
  end
end
