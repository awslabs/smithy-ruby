# frozen_string_literal: true

describe 'Client: Client' do
  ['generated client gem', 'generated client from source code'].each do |context|
    next if ENV['SMITHY_RUBY_RBS_TEST'] && context != 'generated client gem'

    context context do
      include_context context, fixture: 'weather'

      subject { Weather::Client.new(endpoint: 'https://example.com') }

      it 'loads plugins' do
        expect(Weather::Client.plugins).to include(Smithy::Client::Plugins::NetHTTP)
      end

      it 'has operation methods' do
        expect(subject).to respond_to(:get_city, :get_current_time, :get_forecast, :list_cities)
      end

      it 'builds input for operations' do
        input = subject.send(:build_input, :get_city, { id: 1 })
        expect(input).to be_a(Smithy::Client::Input)
      end

      # it 'can call operations' do
      #   subject.get_city(city_id: '1')
      # end
    end
  end
end
