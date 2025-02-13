# frozen_string_literal: true

RSpec.shared_examples 'gemspec' do |context|
  context 'single module' do
    include_context context, 'Weather'

    let(:gem_name) do
      if context.include?('schema')
        'weather-schema'
      else
        'weather'
      end
    end

    it 'generates a gemspec with schema suffix' do
      gemspec = File.join(@plan.destination_root, "#{gem_name}.gemspec")
      expect(File.exist?(gemspec)).to be(true)
    end

    it 'has a gem specification' do
      gemspec = File.join(@plan.destination_root, "#{gem_name}.gemspec")
      gem = Gem::Specification.load(gemspec)
      expect(gem.name).to eq(gem_name)
      expect(gem.version).to eq(Gem::Version.new('0.1.0'))
      expect(gem.summary).to eq('Generated gem using Smithy')
      expect(gem.authors).to eq(['Smithy Ruby'])
      expect(gem.files).to include("lib/#{gem_name}/types.rb")
      expect(gem.files).to include("lib/#{gem_name}/shapes.rb")
      dependency = context.include?('schema') ? 'smithy-model' : 'smithy-client'
      expect(gem.dependencies).to include(Gem::Dependency.new(dependency, '~> 1'))
    end
  end

  context 'nested module' do
    include_context context, 'SomeOrganization::Weather', fixture: 'weather'

    let(:gem_name) do
      if context.include?('schema')
        'some_organization-weather-schema'
      else
        'some_organization-weather'
      end
    end

    it 'generates a gemspec with schema suffix' do
      gemspec = File.join(@plan.destination_root, "#{gem_name}.gemspec")
      expect(File.exist?(gemspec)).to be(true)
    end

    it 'has a gem specification' do
      gemspec = File.join(@plan.destination_root, "#{gem_name}.gemspec")
      gem = Gem::Specification.load(gemspec)
      expect(gem.name).to eq(gem_name)
      expect(gem.version).to eq(Gem::Version.new('0.1.0'))
      expect(gem.summary).to eq('Generated gem using Smithy')
      expect(gem.authors).to eq(['Smithy Ruby'])
      expect(gem.files).to include("lib/#{gem_name}/types.rb")
      expect(gem.files).to include("lib/#{gem_name}/shapes.rb")
      dependency = context.include?('schema') ? 'smithy-model' : 'smithy-client'
      expect(gem.dependencies).to include(Gem::Dependency.new(dependency, '~> 1'))
    end
  end
end
