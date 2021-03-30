# frozen_string_literal: true

require 'seahorse/json/engines'

module Seahorse
  module JSON
    module Engines
      describe Oj do
        subject { described_class }

        describe '.available?' do
          context 'gem is loaded' do
            it 'returns true' do
              expect(subject).to receive(:require).with('oj').and_return(true)
              expect(subject.available?).to be true
            end
          end

          context 'gem is not loaded' do
            it 'returns false' do
              expect(subject).to receive(:require)
                .with('oj').and_raise(LoadError)
              expect(subject.available?).to be false
            end
          end
        end

        describe '.load' do
          context 'valid json' do
            it 'loads the json' do
              hash = { 'foo' => 'bar' }
              expect(subject.load(hash.to_json)).to eq hash
            end
          end

          context 'invalid json' do
            it 'raises a ParseError' do
              value = 'not valid json'
              expect { subject.load(value) }.to raise_error(ParseError)
            end
          end
        end

        describe '.dump' do
          it 'dumps the values to JSON' do
            hash = { 'foo' => 'bar' }
            expect(subject.dump(hash)).to eq hash.to_json
          end
        end
      end
    end
  end
end
