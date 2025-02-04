# frozen_string_literal: true

RSpec.shared_context 'generated client' do |module_names|
  before(:all) do
    @tmpdir = SpecHelper.generate(module_names, :client)
  end

  after(:all) do
    SpecHelper.cleanup_generated(module_names, @tmpdir)
  end
end

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

  include_context 'generated client', ['Weather']

  it 'includes Thor::Actions' do
    expect(Class.new(Smithy::Weld).ancestors).to include(Thor::Actions)
  end

  it 'can pre process the model' do
    weld = Weather::Types::Weld.new
    expect(weld).to be_a(Struct)
    expect(weld.members).to be_empty
    get_forecast_output = Weather::Types::GetForecastOutput.new
    expect(get_forecast_output.members).to include(:chance_of_welds)
  end

  it 'can post process files' do
    other_weld = Weather::Types::OtherWeld.new
    expect(other_weld).to be_a(Struct)
  end

  it 'does not apply welds that return false in #for?' do
    expect(defined?(Weather::Types::WeldShouldNotExist)).to be nil
    expect(defined?(Weather::Types::OtherWeldShouldNotExist)).to be nil
  end
end
