# frozen_string_literal: true

describe 'Component: Client', rbs_test: true do
  include_context 'generated client gem', fixture: 'weather'

  subject { Weather::Client.new }

  # it 'adds the HTTP plugin' do
  #   expect(Weather::Client.plugins).to include(Smithy::Client::Plugins::NetHTTP)
  # end

  it 'has operation methods' do
    expect(subject).to respond_to(:get_city, :get_current_time, :get_forecast, :list_cities)
  end

  it 'builds input for operations' do
    input = subject.send(:build_input, :get_city, { id: 1 })
    expect(input).to be_a(Smithy::Client::Input)
  end

  # it 'can call operations' do
  #   subject.get_city(id: 1)
  # end
end
