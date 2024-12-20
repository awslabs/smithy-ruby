# frozen_string_literal: true

module Smithy
  module Vise
    describe OperationIndex do
      let(:fixture) do
        JSON.load_file(File.expand_path('../../fixtures/vise/model.json', __dir__))
      end

      subject { described_class.new(fixture) }

      describe '#for' do
        it 'returns a complete set of operations for the service' do
          service =
            fixture['shapes']
            .select { |_, shape| shape['type'] == 'service' }
          expected =
            fixture['shapes']
            .select { |_, shape| shape['type'] == 'operation' }
            .reject { |id, _| id.include?('OrphanedOperation') }
          actual = subject.for(service)
          expect(actual.keys).to match_array(expected.keys)
        end
      end
    end
  end
end
