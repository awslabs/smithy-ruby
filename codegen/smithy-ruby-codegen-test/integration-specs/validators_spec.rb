# frozen_string_literal: true

require_relative 'spec_helper'

module SampleService
  module Validators
    describe GetHighScoreInput do
      let(:id) { 'string'}
      let(:input) { Shapes::GetHighScoreInput.new(id: id) }

      it 'accepts a string' do
        GetHighScoreInput.validate!(input, context: 'input')
      end

      context 'id is not a string' do
        let(:id) { 1 }

        it 'raises an ArgumentError with the context' do
          expect {
            GetHighScoreInput.validate!(input, context: 'input')
          }.to raise_error(ArgumentError, 'Expected input[:id] to be in [String], got Integer.')
        end
      end
    end
    describe UpdateHighScoreInput do
      let(:id) { 'string' }
      let(:high_score) { nil }
      let(:input) { Shapes::UpdateHighScoreInput.new(id: id, high_score: high_score) }

      context ':high_score not set' do
        it 'does not validate :high_score' do
          expect(HighScoreParams).not_to receive(:validate!)
          UpdateHighScoreInput.validate!(input, context: 'input')
        end
      end

      context ':high_score set' do
        let(:high_score) { Shapes::HighScoreParams.new }
        it 'validates :high_score' do
          expect(HighScoreParams).to receive(:validate!)
          UpdateHighScoreInput.validate!(input, context: 'input')
        end
      end
    end

    describe SimpleList do
      it 'raises when not an array' do
        expect do
          SimpleList.validate!({}, context: 'input')
        end.to raise_error(ArgumentError, 'Expected input to be in [Array], got Hash.')
      end

      it 'validates all of the members' do
        SimpleList.validate!(['a', 'b', 'c'], context: 'input')
      end

      it 'validates all of the members and raises when any are invalid' do
        expect do
          SimpleList.validate!(['a', 'b', 1], context: 'input')
        end.to raise_error(ArgumentError, 'Expected input[2] to be in [String], got Integer.')
      end
    end

    describe ComplexList do
      let(:high_score) { Shapes::HighScoreAttributes.new }
      it 'raises when not an array' do
        expect do
          ComplexList.validate!({}, context: 'input')
        end.to raise_error(ArgumentError, 'Expected input to be in [Array], got Hash.')
      end

      it 'validates all of the members' do
        ComplexList.validate!([high_score, high_score], context: 'input')
      end

      # TODO: This test is currently broken - requires rework of input (Shape) building + validation
      # it 'validates all of the members and raises when any are invalid' do
      #   #expect do
      #   ComplexList.validate!([high_score, high_score, 1], context: 'input')
      #     # end.to raise_error(ArgumentError, 'Expected input[2] to be in [SampleService::Shapes::HighScoreAttributes.], got Integer.')
      # end
    end
  end
end
