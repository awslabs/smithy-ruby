# frozen_string_literal: true

module Smithy
  module Vise
    describe ServiceIndex do
      let(:fixture) do
        JSON.load_file(File.expand_path('../../fixtures/service_index/model.json', __dir__))
      end

      subject { described_class.new(fixture) }

      describe '#operations_for' do
        it 'returns a complete set of operations for the service' do
          service =
            fixture['shapes']
            .select { |_, shape| shape['type'] == 'service' }
          expected =
            fixture['shapes']
            .select { |_, shape| shape['type'] == 'operation' }
            .reject { |id, _| id.include?('OrphanedOperation') }
          actual = subject.operations_for(service)
          expect(actual.keys).to match_array(expected.keys)
        end
      end

      describe '#shapes_for' do
        it 'returns a complete set of shapes for the service' do
          service =
            fixture['shapes']
            .select { |id, _| id == 'smithy.ruby.tests#ServiceIndex' }
          expected =
            fixture['shapes']
            .reject { |_, shape| %w[operation resource service].include?(shape['type']) }
            .reject { |id, _| id.include?('OrphanedError') || id.include?('OrphanedStructure') }
          actual = subject.shapes_for(service)
          expect(actual.keys).to match_array(expected.keys)
        end
      end
    end
  end
end
