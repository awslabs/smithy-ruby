# frozen_string_literal: true

describe 'Schema: Types', rbs_test: true do
  ['generated schema gem', 'generated schema from source code'].each do |context|
    next if ENV['SMITHY_RUBY_RBS_TEST'] && context != 'generated schema gem'

    context context do
      include_context context, fixture: 'shapes'

      it 'generates a types module' do
        expect(ShapeService::Types).to be_a(Module)
      end

      it 'has structures as structs that include Structure' do
        expect(ShapeService::Types::Structure).to be < Struct
        expect(ShapeService::Types::Structure).to include(Smithy::Client::Structure)
      end

      it 'has unions that define member subclasses' do
        expect(ShapeService::Types::Union).to be < Smithy::Client::Union
        expect(ShapeService::Types::Union::Structure).to be < ShapeService::Types::Union
      end

      it 'supports nested to_h' do
        structure = ShapeService::Types::Structure.new(member: 'member')
        union = ShapeService::Types::Union::Structure.new(structure)
        input_output = ShapeService::Types::OperationInputOutput.new(
          string: 'string',
          union: union
        )
        expected = {
          string: 'string',
          union: { structure: { member: 'member' } }
        }
        expect(input_output.to_h).to eq(expected)
      end
    end
  end
end
