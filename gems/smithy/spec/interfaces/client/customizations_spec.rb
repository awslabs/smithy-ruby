# frozen_string_literal: true

describe 'Component: Customizations' do
  include_context 'generated client gem', fixture: 'weather'

  subject { Weather::Client.new(endpoint: 'https://example.com') }

  it 'should have a customizations file' do
    expect(File).to exist(File.join(@plan.destination_root, 'lib', 'weather', 'customizations.rb'))
  end

  it 'should require the customizations file' do
    expect(require('weather/customizations')).to eq(false)
  end

  it 'does not overwrite an existing customizations file' do
    customization = <<~RUBY
      module Weather
        # @api private
        module Customizations; end
      end
    RUBY
    customizations_file = File.join(@plan.destination_root, 'lib', 'weather', 'customizations.rb')
    expect(File.read(customizations_file)).to_not include(customization)
    File.write(customizations_file, customization)
    SpecHelper.generate_client_gem(fixture: 'weather', destination_root: @plan.destination_root)
    expect(File.read(customizations_file)).to include(customization)
  end
end
