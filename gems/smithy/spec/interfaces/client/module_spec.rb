# frozen_string_literal: true

describe 'Component: Module' do
  %i[schema client].each do |plan_type|
    context 'single module' do
      before(:all) do
        @tmpdir = SpecHelper.generate(['Weather'], plan_type)
      end

      after(:all) do
        SpecHelper.cleanup(['Weather'], @tmpdir)
      end

      let(:gem_name) { "weather#{plan_type == :schema ? '-schema' : ''}" }

      it 'has a version' do
        expect(Weather::VERSION).to eq('1.0.0')
      end

      it 'requires interfaces' do
        expect(Weather::Types).to be_a(Module)
        expect(Weather::Shapes).to be_a(Module)
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

      it 'has a version' do
        expect(SomeOrganization::Weather::VERSION).to eq('1.0.0')
      end

      it 'requires interfaces' do
        expect(SomeOrganization::Weather::Types).to be_a(Module)
        expect(SomeOrganization::Weather::Shapes).to be_a(Module)
      end
    end
  end
end
