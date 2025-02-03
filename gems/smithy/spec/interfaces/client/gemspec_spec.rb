# frozen_string_literal: true

describe 'Component: Gemspec' do
  %i[schema client].each do |plan_type|
    context "#{plan_type} generator" do
      context 'single module' do
        before(:all) do
          @tmpdir = SpecHelper.generate(['Weather'], plan_type)
        end

        after(:all) do
          SpecHelper.cleanup(['Weather'], @tmpdir)
        end

        let(:gem_name) { "weather#{plan_type == :schema ? '-schema' : ''}" }

        it 'generates a gemspec with schema suffix' do
          gemspec = File.join(@tmpdir, "#{gem_name}.gemspec")
          expect(File.exist?(gemspec)).to be(true)
        end

        it 'has a gem specification' do
          gemspec = File.join(@tmpdir, "#{gem_name}.gemspec")
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
        before(:all) do
          @tmpdir = SpecHelper.generate(%w[SomeOrganization Weather], plan_type, fixture: 'weather')
        end

        after(:all) do
          SpecHelper.cleanup(%w[SomeOrganization Weather], @tmpdir)
        end

        let(:gem_name) { "some_organization-weather#{plan_type == :schema ? '-schema' : ''}" }

        it 'generates a gemspec with schema suffix' do
          gemspec = File.join(@tmpdir, "#{gem_name}.gemspec")
          expect(File.exist?(gemspec)).to be(true)
        end

        it 'has a gem specification' do
          gemspec = File.join(@tmpdir, "#{gem_name}.gemspec")
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
