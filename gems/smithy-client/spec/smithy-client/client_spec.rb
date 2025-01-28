# frozen_string_literal: true

# THIS IS NOT going to be committed

module Smithy
  describe Client do
    let(:shapes) { ClientHelper.sample_shapes }

    let(:sample) { ClientHelper.sample_client(shapes: shapes) }

    let(:client) { sample.const_get(:Client) }

    let(:schema) { sample.const_get(:Shapes).const_get(:SCHEMA) }

    it 'makes a client' do
      expect(client.new(endpoint: 'https://foo.com')).to be_a(Smithy::Client::Base)
    end
  end
end
