# frozen_string_literal: true

module Smithy
  module Model
    describe Shape do
      let(:namespace) { 'name.space' }
      let(:shape_name) { 'Shape' }
      let(:member_name) { 'member' }

      let(:relative_id) { "#{shape_name}$#{member_name}" }
      let(:absolute_id) { "#{namespace}##{relative_id}" }
      let(:namespaced_id) { "#{namespace}##{shape_name}" }

      describe '.namespace' do
        it 'returns the namespace' do
          expect(Shape.namespace(absolute_id)).to eq(namespace)
        end

        it 'returns nil when there is no namespace' do
          expect(Shape.namespace(relative_id)).to be_nil
        end
      end

      describe '.relative_id' do
        it 'returns the relative ID' do
          expect(Shape.relative_id(absolute_id)).to eq(relative_id)
        end

        it 'returns nil when the ID is empty' do
          expect(Shape.relative_id('')).to be_nil
        end
      end

      describe '.name' do
        it 'returns the shape name' do
          expect(Shape.name(absolute_id)).to eq(shape_name)
        end

        it 'returns nil when the ID is empty' do
          expect(Shape.name('')).to be_nil
        end
      end

      describe '.member_name' do
        it 'returns the member name' do
          expect(Shape.member_name(absolute_id)).to eq(member_name)
        end

        it 'returns nil when there is no member name' do
          expect(Shape.member_name(namespaced_id)).to be_nil
        end
      end
    end
  end
end
