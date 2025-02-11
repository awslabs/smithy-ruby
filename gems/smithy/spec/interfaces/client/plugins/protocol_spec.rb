# frozen_string_literal: true

describe 'Client: Protocol Plugin', rbs_test: true do
  ['generated client gem', 'generated client from source code'].each do |context|
    next if ENV['SMITHY_RUBY_RBS_TEST'] && context != 'generated client gem'

    context context do
      include_context context, fixture: 'multi_protocol'

      subject { MultiProtocol::Client.new(endpoint: 'https://example.com') }

      it 'is generated' do
        expect(MultiProtocol::Client.plugins).to include(MultiProtocol::Plugins::Protocol)
      end

      it 'sets the default protocol' do
        expect(subject.config.protocol).to be_a(Smithy::Client::Protocols::RPCv2)
      end

      it 'can override the default protocol' do
        custom_protocol = Smithy::Client::Protocols::RPCv2.new(query_compatible: true)
        client = MultiProtocol::Client.new(endpoint: 'https://example.com', protocol: custom_protocol)
        expect(client.config.protocol).to eq(custom_protocol)
      end
    end

    context context do
      include_context context, fixture: 'no_protocol'

      subject { NoProtocol::Client.new(endpoint: 'https://example.com') }

      it 'is generated' do
        expect(NoProtocol::Client.plugins).to include(NoProtocol::Plugins::Protocol)
      end

      it 'does not set a default protocol' do
        expect(subject.config.protocol).to be_nil
      end
    end
  end
end
