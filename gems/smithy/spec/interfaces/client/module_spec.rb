# frozen_string_literal: true

describe 'Component: Module' do
  # TODO: schema
  %i[client].each do |plan_type|
    context "#{plan_type} generator" do
      context 'single module' do
        include_context 'generated client gem', fixture: 'weather'

        let(:gem_name) { "weather#{plan_type == :schema ? '-schema' : ''}" }

        it 'has a version' do
          expect(Weather::VERSION).to eq('0.1.0')
        end

        it 'requires interfaces' do
          expect(Weather::Types).to be_a(Module)
          expect(Weather::Shapes).to be_a(Module)
        end
      end

      context 'nested module' do
        include_context 'generated client gem', fixture: 'weather', module_name: 'SomeOrganization::Weather'

        let(:gem_name) { "some_organization-weather#{plan_type == :schema ? '-schema' : ''}" }

        it 'has a version' do
          expect(SomeOrganization::Weather::VERSION).to eq('0.1.0')
        end

        it 'requires interfaces' do
          expect(SomeOrganization::Weather::Types).to be_a(Module)
          expect(SomeOrganization::Weather::Shapes).to be_a(Module)
        end
      end
    end
  end
end
