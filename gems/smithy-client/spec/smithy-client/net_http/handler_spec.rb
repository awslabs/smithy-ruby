# frozen_string_literal: true

module Smithy
  module Client
    module NetHTTP
      describe Handler do
        let(:client_class) do
          client_class = Class.new(Client::Base)
          client_class.add_plugin(Plugins::Logging)
          client_class.add_plugin(Plugins::NetHTTP)
          client_class
        end

        let(:context) do
          client = client_class.new
          context = HandlerContext.new(config: client.config)
          context.request.endpoint = endpoint
          context
        end

        def endpoint
          @endpoint ||= 'https://example.com'
        end

        let(:make_request) { subject.call(context) }

        subject { Handler.new }

        describe '#call' do
          let(:http_request) { context.request }

          it 'returns an Output object from #call' do
            stub_request(:any, endpoint)
            output = make_request
            expect(output).to be_kind_of(Output)
          end

          it 'populates the #context of the returned response' do
            stub_request(:any, endpoint)
            output = make_request
            expect(output.context).to be(context)
          end

          describe 'request endpoint' do
            it 'makes a request against the given endpoint' do
              @endpoint = 'http://foo.bar.com'
              stub_request(:any, 'http://foo.bar.com')
              make_request
            end

            it 'observes the Endpoint#port' do
              @endpoint = 'http://foo.bar.com:9876'
              stub_request(:any, 'http://foo.bar.com:9876')
              make_request
            end

            it 'observes the Endpoint#scheme' do
              @endpoint = 'https://foo.bar.com'
              stub_request(:any, 'https://foo.bar.com')
              make_request
            end
          end

          describe 'request http method' do
            it 'uses the request#http_method to make the request' do
              http_request.http_method = 'POST'
              stub_request(:post, endpoint)
              make_request
            end

            it 'raises a helpful error if the request method is invalid' do
              http_request.http_method = 'abc'
              output = make_request
              expect(output.error).to be_a(ArgumentError)
            end
          end

          describe 'request headers' do
            it 'passes along request#headers' do
              http_request.headers['abc'] = 'xyz'
              stub_request(:any, endpoint).with(headers: { 'abc' => 'xyz' })
              make_request
            end

            # it 'populates a default accept-encoding header' do
            #   # this prevents net/http from setting accept-encoding on our behalf
            #   stub_request(:any, endpoint).
            #     with(:headers => { 'accept-encoding' => '' })
            #   make_request
            # end
            #
            # it 'does not clobber a custom accept-encoding' do
            #   http_request.headers['Accept-Encoding'] = 'text/plain'
            #   stub_request(:any, endpoint).
            #     with(headers: { 'accept-encoding' => 'text/plain' })
            #   make_request
            # end
          end

          describe 'request path' do
            it 'sends the request with the correct request uri' do
              http_request.endpoint.path = '/path'
              stub_request(:any, http_request.endpoint.to_s)
              make_request
            end

            it 'sends the request with the querystring' do
              http_request.endpoint.path = '/abc'
              http_request.endpoint.query = 'mno=xyz'
              stub_request(:any, http_request.endpoint.to_s)
              make_request
            end
          end

          describe 'request body' do
            it 'sends the body' do
              http_request.body = StringIO.new('request-body')
              stub_request(:any, endpoint).with(body: 'request-body')
              make_request
            end
          end

          describe 'response' do
            it 'populates the status code' do
              stub_request(:any, endpoint).to_return(status: 200)
              output = make_request
              expect(output.context.response.status_code).to eq(200)
            end

            it 'populates the headers' do
              stub_request(:any, endpoint).to_return(headers: { 'Content-Length' => '0' })
              output = make_request
              expect(output.context.response.headers['Content-Length']).to eq('0')
            end

            it 'populates the response body' do
              stub_request(:any, endpoint).to_return(body: 'response-body')
              resp_body = make_request.context.response.body
              resp_body.rewind
              expect(resp_body.read).to eq('response-body')
            end

            it 'wraps errors with a NetworkingError' do
              stub_request(:any, endpoint).to_raise(EOFError)
              output = make_request
              expect(output.error).to be_a(Smithy::Client::NetworkingError)
            end

            it 'wraps errors for proxies with a NetworkingError' do
              error = Net::HTTPFatalError.new('Gateway Time-out', nil)
              stub_request(:any, endpoint).to_raise(error)
              output = make_request
              expect(output.error).to be_a(Smithy::Client::NetworkingError)
            end

            it 'wraps OpenSSL errors with a NetworkingError' do
              stub_request(:any, endpoint).to_raise(OpenSSL::SSL::SSLError)
              output = make_request
              expect(output.error).to be_a(Smithy::Client::NetworkingError)
            end

            it 'raises when content length and body length mismatch' do
              stub_request(:any, endpoint).to_return(body: 'foo', headers: { 'Content-Length' => 1 })
              output = make_request
              expect(output.error).to be_a(Smithy::Client::NetworkingError)
            end
          end
        end
      end
    end
  end
end
