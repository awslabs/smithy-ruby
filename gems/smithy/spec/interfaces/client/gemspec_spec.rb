# frozen_string_literal: true

describe 'Component: Gemspec' do
  # TODO: schema
  %i[client].each do |plan_type|
    context "#{plan_type} generator" do
      context 'single module' do
        include_context 'generated client gem', fixture: 'weather'

        let(:gem_name) { "weather#{plan_type == :schema ? '-schema' : ''}" }

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
          expect(gem.dependencies).to include(Gem::Dependency.new('smithy-client', '~> 1'))
        end
      end

      context 'nested module' do
        include_context 'generated client gem', fixture: 'weather', module_name: 'SomeOrganization::Weather'

        let(:gem_name) { "some_organization-weather#{plan_type == :schema ? '-schema' : ''}" }

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
          expect(gem.dependencies).to include(Gem::Dependency.new('smithy-client', '~> 1'))
        end
      end
    end
  end
end
