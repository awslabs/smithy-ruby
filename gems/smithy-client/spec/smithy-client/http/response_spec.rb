# frozen_string_literal: true

module Smithy
  module Client
    module HTTP
      describe Response do
        subject { Response.new }

        describe '#status_code' do
          it 'defaults to 0' do
            expect(subject.status_code).to eq(0)
          end

          it 'can be set' do
            subject.status_code = 500
            expect(subject.status_code).to eq(500)
          end
        end

        describe '#headers' do
          it 'is a HTTP::Headers' do
            expect(subject.headers).to be_kind_of(Headers)
          end

          it 'defaults to a empty hash' do
            expect(subject.headers.to_h).to eq({})
          end

          it 'can be set' do
            headers = Headers.new
            subject.headers = headers
            expect(subject.headers).to be(headers)
          end
        end

        describe '#body' do
          it 'defaults to an empty IO-like object' do
            expect(subject.body.read).to eq('')
          end

          it 'can be set in the constructor' do
            body = StringIO.new('body')
            expect(Response.new(body: body).body).to be(body)
          end

          it 'converts nil bodies into empty io objects' do
            subject.body = nil
            expect(subject.body.read).to eq('')
          end

          it 'can be set as a string in the accessor' do
            subject.body = 'body'
            expect(subject.body).to be_a(StringIO)
            expect(subject.body.read).to eq('body')
          end

          it 'can set a string io in the accessor' do
            subject.body = StringIO.new('body')
            expect(subject.body.read).to eq('body')
          end
        end

        describe '#reset' do
          it 'resets the body' do
            body = StringIO.new
            body << 'data'
            response = Response.new(
              body: body,
              headers: Headers.new('Content-Length' => '4'),
              status_code: 200,
              error: StandardError.new('error')
            )
            response.reset
            expect(response.body.read).to eq('')
            expect(response.headers.to_h).to eq({})
            expect(response.status_code).to eq(0)
            expect(response.error).to be_nil
          end
        end

        describe '#signal_headers' do
          it 'sets the status code' do
            subject.signal_headers(200, {})
            expect(subject.status_code).to eq(200)
          end

          it 'sets the headers' do
            headers = { 'content-length' => '4' }
            subject.signal_headers(200, headers)
            expect(subject.headers['content-length']).to eq('4')
          end
        end

        describe '#signal_data' do
          it 'sets the data' do
            subject.signal_data('data')
            subject.signal_done
            expect(subject.body.read).to eq('data')
          end

          it 'does not write empty data' do
            subject.signal_data('')
            subject.signal_done
            expect(subject.body.read).to eq('')
          end
        end

        describe '#signal_done' do
          it 'raises when the response does not have all of the required keys' do
            expect { subject.signal_done(foo: 'bar') }.to raise_error(ArgumentError)
          end

          it 'emits done without arguments' do
            done = false
            subject.on_done { |response| done = true }
            subject.signal_done
            expect(done).to be(true)
          end

          it 'rewinds the body' do
            body = StringIO.new('data')
            subject.body = body
            subject.signal_done
            expect(subject.body.read).to eq('data')
          end

          it 'emits status code, headers, and body' do
            subject.signal_done(
              status_code: 200,
              headers: { 'content-length' => 4 },
              body: 'data'
            )
            expect(subject.status_code).to eq(200)
            expect(subject.headers['content-length']).to eq('4')
            expect(subject.body.read).to eq('data')
          end
        end

        describe '#signal_error' do
          it 'sets the error' do
            error = StandardError.new('error')
            subject.signal_error(error)
            expect(subject.error).to be(error)
          end
        end

        describe '#on_headers' do
          it 'yields the status code and headers' do
            headers = nil
            subject.on_headers { |status_code, h| headers = h }
            subject.signal_headers(200, { 'content-length' => 4 })
            expect(headers['content-length']).to eq('4')
          end
        end

        describe '#on_data' do
          it 'yields the data' do
            data = nil
            subject.on_data { |d| data = d }
            subject.signal_data('data')
            expect(data).to eq('data')
          end
        end

        describe '#on_done' do
          it 'yields when the response is done' do
            done = false
            subject.on_done { done = true }
            subject.signal_done
            expect(done).to be(true)
          end
        end

        describe '#on_success' do
          it 'yields when the response is done and does not have an error' do
            success = false
            subject.on_success { success = true }
            subject.signal_done(status_code: 200, headers: {}, body: '')
            expect(success).to be(true)
          end

          it 'does not yield when the response has an error' do
            success = false
            subject.signal_error(StandardError.new('error'))
            subject.on_success { success = true }
            subject.signal_done
            expect(success).to be(false)
          end
        end

        describe '#on_error' do
          it 'yields when the response has an error' do
            error = nil
            subject.on_error { |e| error = e }
            subject.signal_error(StandardError.new('error'))
            expect(error).to be_kind_of(StandardError)
          end

          it 'does not yield when the response does not have an error' do
            error = nil
            subject.on_error { |e| error = e }
            subject.signal_done
            expect(error).to be_nil
          end
        end

      end
    end
  end
end
