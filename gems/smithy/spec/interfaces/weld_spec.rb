# frozen_string_literal: true

describe 'Integration: Welds' do
  # rubocop:disable Lint/UselessAssignment
  before(:all) do
    # Define Weld classes (scoped to this block only)
    used = Class.new(Smithy::Weld) do
      def pre_process(model)
        model['shapes']['smithy.ruby.tests.weather#Weld'] = { 'type' => 'structure', 'members' => {} }
        model['shapes']['smithy.ruby.tests.weather#GetForecastOutput']['members']['chanceOfWelds'] =
          { 'target' => 'smithy.ruby.tests.weather#Weld' }
      end

      def post_process(artifacts)
        file = artifacts.find { |f| f.include?('/types.rb') }
        inject_into_module(file, 'Types') do
          "    OtherWeld = Struct.new(keyword_init: true)\n"
        end
      end
    end

    unused = Class.new(Smithy::Weld) do
      def for?(_service)
        false
      end

      def pre_process(model)
        model['shapes']['smithy.ruby.tests.weather#WeldShouldNotExist'] = { 'type' => 'structure', 'members' => {} }
        model['shapes']['smithy.ruby.tests.weather#GetForecastOutput']['members']['chanceOfWelds'] =
          { 'target' => 'smithy.ruby.tests.weather#WeldShouldNotExist' }
      end

      def post_process(artifacts)
        file = artifacts.find { |f| f.include?('/types.rb') }
        inject_into_module(file, 'Types') do
          "    OtherWeldShouldNotExist = Struct.new(keyword_init: true)\n"
        end
      end
    end
  end
  # rubocop:enable Lint/UselessAssignment

  it 'includes Thor::Actions' do
    expect(Class.new(Smithy::Weld).ancestors).to include(Thor::Actions)
  end

  ['generated client gem',
   'generated schema gem',
   'generated client from source code',
   'generated schema from source code'].each do |context|
    context context do
      include_examples 'welds', context
    end
  end
end
