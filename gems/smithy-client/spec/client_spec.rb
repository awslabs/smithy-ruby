# frozen_string_literal: true

# THIS IS NOT going to be committed

module Smithy
  describe Client do

    let(:shapes) { ClientHelper.sample_shapes }

    let(:client) { ClientHelper.sample_client(shapes: shapes) }

    let(:schema) { service.const_get(:Shapes).const_get(:SCHEMA) }

    it 'makes a client' do
      expect(client.new(endpoint: 'https://foo.com')).to be_a(Smithy::Client::Base)
    end
  end
end