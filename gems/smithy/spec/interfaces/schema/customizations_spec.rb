# frozen_string_literal: true

describe 'Schema: Customizations' do
  include_context 'generated schema gem', fixture: 'weather'

  it 'should have a customizations file' do
    expect(File).to exist(File.join(@plan.destination_root, 'lib', 'weather-schema', 'customizations.rb'))
  end

  it 'should require the customizations file' do
    expect(require('weather-schema/customizations')).to eq(false)
  end

  it 'does not overwrite an existing customizations file' do
    customization = <<~RUBY
      module Weather
        # @api private
        module Customizations; end
      end
    RUBY
    customizations_file = File.join(@plan.destination_root, 'lib', 'weather-schema', 'customizations.rb')
    expect(File.read(customizations_file)).to_not include(customization)
    File.write(customizations_file, customization)
    SpecHelper.generate_gem(:schema, fixture: 'weather', destination_root: @plan.destination_root)
    expect(File.read(customizations_file)).to include(customization)
  end
end
