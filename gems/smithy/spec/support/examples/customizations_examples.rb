# frozen_string_literal: true

RSpec.shared_examples 'customizations' do |context|
  include_context context, fixture: 'weather'

  let(:gem_name) do
    context.include?('schema') ? 'weather-schema' : 'weather'
  end

  it 'should have a customizations file' do
    expect(File).to exist(File.join(@plan.destination_root, 'lib', gem_name, 'customizations.rb'))
  end

  it 'should require the customizations file' do
    expect(require("#{gem_name}/customizations")).to eq(false)
  end

  it 'does not overwrite an existing customizations file' do
    customization = <<~RUBY
      module Weather
        # @api private
        module Customizations; end
      end
    RUBY
    customizations_file = File.join(@plan.destination_root, 'lib', gem_name, 'customizations.rb')
    expect(File.read(customizations_file)).to_not include(customization)
    File.write(customizations_file, customization)
    SpecHelper.generate_gem(@plan.type, fixture: 'weather', destination_root: @plan.destination_root)
    expect(File.read(customizations_file)).to include(customization)
  end
end
