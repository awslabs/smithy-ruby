# frozen_string_literal: true

module Smithy
  module Vise
    describe OperationIndex do
      let(:fixture) do
        JSON.load_file(File.expand_path('../../fixtures/operation_index/model.json', __dir__))
      end

      subject { described_class.new(fixture) }

      describe '#shapes_for' do
        it 'returns a complete set of shapes for the operation' do
          operation =
            fixture['shapes']
            .select { |id, _| id == 'smithy.ruby.tests#Operation' }
          expected =
            fixture['shapes']
            .reject { |_, shape| %w[operation service].include?(shape['type']) }
            .reject { |id, _| id.include?('OrphanedError') || id.include?('OrphanedStructure') }
          actual = subject.shapes_for(operation)
          expect(actual.keys).to match_array(expected.keys)
        end

        it 'is memoized' do
          operation =
            fixture['shapes']
            .select { |id, _| id == 'smithy.ruby.tests#Operation' }
          before = subject.shapes_for(operation)
          fixture['shapes'].delete('smithy.ruby.tests#Operation')
          expect(subject.shapes_for(operation)).to eq(before)
        end
      end
    end
  end
end
