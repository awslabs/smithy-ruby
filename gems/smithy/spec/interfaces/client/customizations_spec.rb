# frozen_string_literal: true

describe 'Component: Customizations' do
  before(:all) do
    @tmpdir = SpecHelper.generate(['Weather'], :client)
  end

  after(:all) do
    SpecHelper.cleanup(['Weather'], @tmpdir)
  end

  subject { Weather::Client.new(endpoint: 'https://example.com') }

  it 'should have a customizations file' do
    expect(File).to exist(File.join(@tmpdir, 'lib', 'weather', 'customizations.rb'))
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
    customizations_file = File.join(@tmpdir, 'lib', 'weather', 'customizations.rb')
    expect(File.read(customizations_file)).to_not include(customization)
    File.write(customizations_file, customization)
    SpecHelper.generate(['Weather'], :client, destination_root: @tmpdir)
    expect(File.read(customizations_file)).to include(customization)
  end
end
