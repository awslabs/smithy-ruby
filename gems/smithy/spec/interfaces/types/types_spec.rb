# frozen_string_literal: true

describe 'Types: Types interface' do
  before(:all) do
    SpecHelper.generate(['Weather'], :types)
  end

  after(:all) do
    SpecHelper.cleanup(['Weather'])
  end

  it 'generates a types module' do
    expect(Weather::Types).to be_a(Module)
  end

  it 'has structures as structs' do
    expect(Weather::Types::CityCoordinates.new).to be_a(Struct)
  end

  it 'supports nested to_h' do
    coordinates = Weather::Types::CityCoordinates.new(latitude: 1.0, longitude: 2.0)
    get_city_output = Weather::Types::GetCityOutput.new(name: 'Winchester', coordinates: coordinates)

    expected = { name: 'Winchester', coordinates: { latitude: 1.0, longitude: 2.0 } }
    actual = get_city_output.to_h
    expect(actual).to eq(expected)
  end
end
