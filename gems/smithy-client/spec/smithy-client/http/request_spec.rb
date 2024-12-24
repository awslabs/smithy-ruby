# frozen_string_literal: true

module Smithy
  module Client
    module HTTP
      describe Request do
        subject { Request.new }

        describe '#endpoint' do
          it 'defaults to nil' do
            expect(subject.endpoint).to eq(nil)
          end

          it 'can be set in the constructor' do
            endpoint = 'https://example.com/'
            req = Request.new(endpoint: endpoint)
            expect(req.endpoint).to eq(URI.parse(endpoint))
          end

          it 'can be blanked out' do
            req = Request.new(endpoint: 'https://example.com')
            req.endpoint = nil
            expect(req.endpoint).to be(nil)
          end

          it 'converts strings to URIs' do
            subject.endpoint = 'http://example.com'
            expect(subject.endpoint).to be_kind_of(URI::HTTP)
            expect(subject.endpoint).to eq(URI.parse('http://example.com'))
          end

          it 'supports https endpoints' do
            subject.endpoint = 'https://example.com'
            expect(subject.endpoint).to be_kind_of(URI::HTTPS)
            expect(subject.endpoint).to eq(URI.parse('https://example.com'))
          end

          it 'raises when endpoint is not a uri' do
            expect { subject.endpoint = 'generic' }
              .to raise_error(ArgumentError)
          end
        end

        describe '#http_method' do
          it 'defaults to GET' do
            expect(subject.http_method).to eq('GET')
          end

          it 'can be set in the constructor' do
            req = Request.new(http_method: 'POST')
            expect(req.http_method).to eq('POST')
          end
        end

        describe '#headers' do
          it 'defaults to a HTTP::Headers' do
            expect(subject.headers).to be_kind_of(Headers)
          end

          it 'casts incoming headers as a Http::Headers object' do
            req = Request.new(headers: { 'User-Agent' => 'ua' })
            expect(req.headers).to be_kind_of(Headers)
          end
        end

        describe '#body' do
          it 'defaults to an empty IO-like object' do
            expect(subject.body.read).to eq('')
          end

          it 'can be set in the constructor' do
            body = StringIO.new('body')
            expect(Request.new(body: body).body).to be(body)
          end

          it 'can be set as a string in the constructor' do
            req = Request.new(body: 'body')
            expect(req.body).to be_a(StringIO)
            expect(req.body.read).to eq('body')
          end

          it 'converts nil bodies into empty io objects' do
            subject.body = nil
            expect(subject.body.read).to eq('')
          end

          it 'can be set as a string in accessor' do
            subject.body = 'body'
            expect(subject.body).to be_a(StringIO)
            expect(subject.body.read).to eq('body')
          end
        end
      end
    end
  end
end
