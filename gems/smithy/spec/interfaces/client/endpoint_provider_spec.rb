# frozen_string_literal: true

describe 'Client: EndpointProvider', rbs_test: true do
  ['generated client gem', 'generated client from source code'].each do |context|
    next if ENV['SMITHY_RUBY_RBS_TEST'] && context != 'generated client gem'

    context context do
      include_context context, 'EndpointDefaults', fixture: 'endpoints/default-values'

      subject { EndpointDefaults::EndpointProvider.new }

      describe '.resolve_endpoint' do
        it 'resolves the endpoint' do
          params = EndpointDefaults::EndpointParameters.new(bar: 'bar', baz: 'baz')

          out = subject.resolve_endpoint(params)
          expect(out).to be_a(Smithy::Client::EndpointRules::Endpoint)
          expect(out.uri).to eq('https://example.com/baz')
        end

        it 'raises errors from rules' do
          params = EndpointDefaults::EndpointParameters.new(bar: nil, baz: 'baz')
          expect do
            subject.resolve_endpoint(params)
          end.to raise_error(ArgumentError, 'endpoint error')
        end
      end
    end
  end
end
