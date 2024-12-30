# frozen_string_literal: true

describe 'Types: Welding' do
  before(:all) do
    # Define Weld classes (scoped to this block only)
    Class.new(Smithy::Weld) do
      def preprocess(model)
        model['shapes']['example.weather#Weld'] = { 'type' => 'structure', 'members' => {} }
        model['shapes']['example.weather#GetForecastOutput']['members']['chanceOfWelds'] =
          { 'target' => 'example.weather#Weld' }
      end
    end

    Class.new(Smithy::Weld) do
      def for?(_model)
        false
      end

      def preprocess(model)
        model['shapes']['example.weather#ShouldNotExist'] = { 'type' => 'structure', 'members' => {} }
        model['shapes']['example.weather#GetForecastOutput']['members']['chanceOfWelds'] =
          { 'target' => 'example.weather#Weld' }
      end
    end

    @tmpdir = SpecHelper.generate(['Weather'], :types)
  end

  after(:all) do
    SpecHelper.cleanup(['Weather'], @tmpdir)
  end

  it 'can preprocess the model' do
    weld = Weather::Types::Weld.new
    expect(weld).to be_a(Struct)
    expect(weld.members).to be_empty
    get_forecast_output = Weather::Types::GetForecastOutput.new
    expect(get_forecast_output.members).to include(:chance_of_welds)
  end

  it 'does not apply welds that return false for for?' do
    expect(defined?(Weather::Types::ShouldNotExist)).to be nil
  end
end
