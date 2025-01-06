# frozen_string_literal: true

# This is generated code!

require_relative '../spec_helper'

module Weather
  describe EndpointProvider do
    subject { EndpointProvider.new }

    context 'Endpoint set' do
      let(:expected) do
        { 'endpoint' => { 'url' => 'https://example.com' } }
      end

      it 'produces the expected output from the EndpointProvider' do
        params = EndpointParameters.new(endpoint: 'https://example.com')
        endpoint = subject.resolve_endpoint(params)
        expect(endpoint.uri).to eq(expected['endpoint']['url'])
        expect(endpoint.headers).to eq(expected['endpoint']['headers'] || {})
        expect(endpoint.properties).to eq(expected['endpoint']['properties'] || {})
      end
    end

    context 'Endpoint not set' do
      let(:expected) do
        { 'error' => 'Endpoint is not set - you must configure an endpoint.' }
      end

      it 'produces the expected output from the EndpointProvider' do
        params = EndpointParameters.new(**{})
        expect do
          subject.resolve_endpoint(params)
        end.to raise_error(ArgumentError, expected['error'])
      end
    end
  end
end
