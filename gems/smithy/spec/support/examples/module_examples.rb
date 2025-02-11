# frozen_string_literal: true

RSpec.shared_examples 'gem module' do |context|
  context 'single module' do
    include_context context, 'Weather'

    it 'has a version' do
      expect(Weather::VERSION).to eq('0.1.0')
    end

    it 'requires interfaces' do
      expect(Weather::Types).to be_a(Module)
      expect(Weather::Shapes).to be_a(Module)
    end
  end

  context 'nested module' do
    include_context context, 'SomeOrganization::Weather', fixture: 'weather'

    it 'has a version' do
      expect(SomeOrganization::Weather::VERSION).to eq('0.1.0')
    end

    it 'requires interfaces' do
      expect(SomeOrganization::Weather::Types).to be_a(Module)
      expect(SomeOrganization::Weather::Shapes).to be_a(Module)
    end
  end
end
