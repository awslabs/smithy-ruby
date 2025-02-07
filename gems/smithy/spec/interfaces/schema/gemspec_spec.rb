# frozen_string_literal: true

describe 'Schema: Gemspec' do
  context 'single module' do
    include_context 'generated schema gem', fixture: 'weather'

    it 'generates a gemspec with schema suffix' do
      gemspec = File.join(@plan.destination_root, 'weather-schema.gemspec')
      expect(File.exist?(gemspec)).to be(true)
    end

    it 'has a gem specification' do
      gemspec = File.join(@plan.destination_root, 'weather-schema.gemspec')
      gem = Gem::Specification.load(gemspec)
      expect(gem.name).to eq('weather-schema')
      expect(gem.version).to eq(Gem::Version.new('0.1.0'))
      expect(gem.summary).to eq('Generated gem using Smithy')
      expect(gem.authors).to eq(['Smithy Ruby'])
      expect(gem.files).to include('lib/weather-schema/types.rb')
      expect(gem.dependencies).to include(Gem::Dependency.new('smithy-client', '~> 1'))
    end
  end

  context 'nested module' do
    include_context 'generated schema gem', fixture: 'weather', module_name: 'SomeOrganization::Weather'

    it 'generates a gemspec with schema suffix' do
      gemspec = File.join(@plan.destination_root, 'some_organization-weather-schema.gemspec')
      expect(File.exist?(gemspec)).to be(true)
    end

    it 'has a gem specification' do
      gemspec = File.join(@plan.destination_root, 'some_organization-weather-schema.gemspec')
      gem = Gem::Specification.load(gemspec)
      expect(gem.name).to eq('some_organization-weather-schema')
      expect(gem.version).to eq(Gem::Version.new('0.1.0'))
      expect(gem.summary).to eq('Generated gem using Smithy')
      expect(gem.authors).to eq(['Smithy Ruby'])
      expect(gem.files).to include('lib/some_organization-weather-schema/types.rb')
      expect(gem.dependencies).to include(Gem::Dependency.new('smithy-client', '~> 1'))
    end
  end
end
