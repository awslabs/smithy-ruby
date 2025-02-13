# frozen_string_literal: true

module Smithy
  module Client
    module Codecs
      describe CBOR do
        let(:string_shape) { Model::Shapes::StringShape.new(id: 'string') }

        let(:list_shape) do
          shape = Model::Shapes::ListShape.new(id: 'list')
          shape.set_member(Model::Shapes::Prelude::String)
          shape
        end

        let(:map_shape) do
          shape = Model::Shapes::MapShape.new(id: 'map')
          shape.set_key(Model::Shapes::Prelude::String)
          shape.set_value(Model::Shapes::Prelude::Blob)
          shape
        end

        let(:typed_struct) do
          Struct.new(:s, :l, :m, keyword_init: true) do
            include Model::Structure
          end
        end

        let(:structure_shape) do
          struct = Model::Shapes::StructureShape.new(id: 'structure')
          struct.add_member(:s, string_shape)
          struct.add_member(:l, list_shape)
          struct.add_member(:m, map_shape)
          struct.type = typed_struct
          struct
        end

        it 'serializes returns nil when given shape is Prelude::Unit' do
          expect(subject.serialize('', Model::Shapes::Prelude::Unit)).to be_nil
        end

        it 'deserializes returns an empty hash when given bytes are empty' do
          expect(subject.deserialize('', string_shape)).to be_empty
        end

        it 'serializes and deserializes a complex data' do
          typed = typed_struct.new(s: 'foo', l: %w[foo bar], m: { 'foo' => 'bar'.dup })
          serialized = subject.serialize(typed, structure_shape)
          expect(subject.deserialize(serialized, structure_shape)).to eq(typed)
        end
      end
    end
  end
end
