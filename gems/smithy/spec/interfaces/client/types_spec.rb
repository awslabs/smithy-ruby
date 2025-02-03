# frozen_string_literal: true

describe 'Component: Types' do
  %i[schema client].each do |plan_type|
    context "#{plan_type} generator" do
      before(:all) do
        @tmpdir = SpecHelper.generate(['AllShapes'], plan_type)
      end

      after(:all) do
        SpecHelper.cleanup(['AllShapes'], @tmpdir)
      end

      it 'generates a types module' do
        expect(AllShapes::Types).to be_a(Module)
      end

      it 'has structures as structs that include Structure' do
        expect(AllShapes::Types::Structure).to be < Struct
        expect(AllShapes::Types::Structure).to include(Smithy::Client::Structure)
      end

      it 'has unions that define member subclasses' do
        expect(AllShapes::Types::Union).to be < Smithy::Client::Union
        expect(AllShapes::Types::Union::Structure).to be < AllShapes::Types::Union
      end

      it 'supports nested to_h' do
        structure = AllShapes::Types::Structure.new(member: 'member')
        simple_list = ['value1']
        complex_list = [structure]
        union = AllShapes::Types::Union::Structure.new(structure)
        input_output = AllShapes::Types::OperationInputOutput.new(
          string: 'string',
          simple_list: simple_list,
          complex_list: complex_list,
          union: union
        )

        expected = {
          string: 'string',
          simple_list: ['value1'],
          complex_list: [{ member: 'member' }],
          union: { structure: { member: 'member' } }
        }
        actual = input_output.to_h
        expect(actual).to eq(expected)
      end
    end
  end
end
