# frozen_string_literal: true

describe 'Component: EndpointProvider' do
  before(:all) do
    @tmpdir = SpecHelper.generate(['Defaults'], :client, fixture: 'endpoints/default-values')
  end

  after(:all) do
    SpecHelper.cleanup(['Defaults'], @tmpdir)
  end

  subject { Defaults::EndpointProvider.new }

  describe '.resolve_endpoint' do
    it 'resolves the endpoint' do
      params = Defaults::EndpointParameters.new(bar: 'bar', baz: 'baz')

      out = subject.resolve_endpoint(params)
      expect(out).to be_a(Smithy::Client::EndpointRules::Endpoint)
      expect(out.uri).to eq('https://example.com/baz')
    end

    it 'raises errors from rules' do
      params = Defaults::EndpointParameters.new(bar: nil, baz: 'baz')
      expect do
        subject.resolve_endpoint(params)
      end.to raise_error(ArgumentError, 'endpoint error')
    end
  end
end
