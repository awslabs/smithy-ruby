# frozen_string_literal: true

module Smithy
  describe Model do
    describe '#shape' do
      let(:model) { { 'shapes' => { 'smithy.ruby.tests#Shape' => { 'type' => 'string' } } } }

      it 'returns a shape' do
        shape = Model.shape(model, 'smithy.ruby.tests#Shape')
        expect(shape).to be_a(Hash)
        expect(shape['type']).to eq('string')
      end

      it 'returns prelude shapes if not present in the model' do
        shape = Model.shape(model, 'smithy.api#Unit')
        expect(shape).to be_a(Hash)
        expect(shape['type']).to eq('structure')
      end

      it 'raises an error when the shape is not found' do
        expect { Model.shape(model, 'smithy.ruby.tests#NoSuchShape') }.to raise_error(ArgumentError)
      end

      context 'mixins' do
        # Tests loosely taken from https://smithy.io/2.0/spec/mixins.html#mixins
        let(:fixture) do
          JSON.load_file(File.expand_path("../fixtures/mixins/#{fixture_name}/model.json", __dir__.to_s))
        end

        context 'vanilla' do
          let(:fixture_name) { 'vanilla' }

          it 'resolves mixins' do
            shape = Model.shape(fixture, 'smithy.ruby.tests#UserDetails')
            expect(shape).to_not have_key('mixins')
            expect(shape['members']['id'])
              .to eq(fixture['shapes']['smithy.ruby.tests#UserIdentifiersMixin']['members']['id'])
          end
        end

      end
    end
  end
end
