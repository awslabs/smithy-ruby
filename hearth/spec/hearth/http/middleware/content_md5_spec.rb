# frozen_string_literal: true

module Hearth
  module HTTP
    module Middleware
      describe ContentLength do
        let(:app) { double('app', call: output) }

        subject { ContentMD5.new(app) }

        describe '#call' do
          let(:input) { double('input') }
          let(:output) { double('output') }

          let(:body) { StringIO.new('test-body') }

          let(:request) do
            Request.new(
              http_method: :get,
              url: 'http://example.com',
              body: body
            )
          end

          let(:response) { double('response') }
          let(:context) do
            Context.new(
              request: request,
              response: response
            )
          end

          context 'Content-MD5 is not set' do
            it 'sets Content-MD5 and calls next middleware' do
              expect(app).to receive(:call).with(input, context)
              expect(Hearth::Checksums).to receive(:md5)
                .with(body).and_return('checksum')
              resp = subject.call(input, context)
              expect(request.headers['Content-MD5']).to eq('checksum')
              expect(resp).to be output
            end
          end

          context 'Content-MD5 is already set' do
            before { request.headers['Content-MD5'] = 'existing' }

            it 'does not calculate a new checksum' do
              expect(app).to receive(:call).with(input, context)
              expect(Hearth::Checksums).not_to receive(:md5)

              resp = subject.call(input, context)
              expect(request.headers['Content-MD5']).to eq('existing')
              expect(resp).to be output
            end
          end
        end
      end
    end
  end
end
