# frozen_string_literal: true

RSpec.shared_examples 'types module' do |context|
  include_context context, 'ShapeService', fixture: 'shapes'

  it 'generates a types module' do
    expect(ShapeService::Types).to be_a(Module)
  end

  it 'has structures as structs that include Structure' do
    expect(ShapeService::Types::Structure).to be < Struct
    expect(ShapeService::Types::Structure).to include(Smithy::Model::Structure)
  end

  it 'has unions that define member subclasses' do
    expect(ShapeService::Types::Union).to be < Smithy::Model::Union
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
