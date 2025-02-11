# frozen_string_literal: true

RSpec.shared_examples 'welds' do |context|
  include_context context, 'Weather'

  it 'can pre process the model' do
    weld = Weather::Types::Weld.new
    expect(weld).to be_a(Struct)
    expect(weld.members).to be_empty
    get_forecast_output = Weather::Types::GetForecastOutput.new
    expect(get_forecast_output.members).to include(:chance_of_welds)
  end

  if context.include?('source code')
    it 'cannot post process files' do
      expect(defined?(Weather::Types::OtherWeld)).to be nil
    end
  else
    it 'can post process files' do
      other_weld = Weather::Types::OtherWeld.new
      expect(other_weld).to be_a(Struct)
    end
  end

  it 'does not apply welds that return false in #for?' do
    expect(defined?(Weather::Types::WeldShouldNotExist)).to be nil
    expect(defined?(Weather::Types::OtherWeldShouldNotExist)).to be nil
  end
end
