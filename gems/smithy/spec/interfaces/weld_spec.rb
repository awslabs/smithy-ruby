# frozen_string_literal: true

describe 'Integration: Welds' do
  # rubocop:disable Lint/UselessAssignment
  before(:all) do
    # Define Weld classes (scoped to this block only)
    used = Class.new(Smithy::Weld) do
      def for?(service)
        service.keys.first == 'smithy.ruby.tests.weather#Weather'
      end

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

  context 'generated client gem' do
    include_context 'generated client gem', { fixture: 'weather' }

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

  context 'generated schema gem' do
    it 'pending'
  end

  context 'source code' do
    include_context 'generated client from source code', { fixture: 'weather' }

    it 'can pre process the model' do
      weld = Weather::Types::Weld.new
      expect(weld).to be_a(Struct)
      expect(weld.members).to be_empty
      get_forecast_output = Weather::Types::GetForecastOutput.new
      expect(get_forecast_output.members).to include(:chance_of_welds)
    end

    it 'cannot post process files' do
      expect(defined?(Weather::Types::OtherWeld)).to be nil
    end

    it 'does not apply welds that return false in #for?' do
      expect(defined?(Weather::Types::WeldShouldNotExist)).to be nil
      expect(defined?(Weather::Types::OtherWeldShouldNotExist)).to be nil
    end
  end
end
