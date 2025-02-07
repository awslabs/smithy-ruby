# frozen_string_literal: true

describe 'Client: Module' do
  context 'single module' do
    ['generated client gem', 'generated client from source code'].each do |context|
      context context do
        include_context context, fixture: 'weather'

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
