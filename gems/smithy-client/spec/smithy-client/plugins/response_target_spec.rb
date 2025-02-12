# frozen_string_literal: true

require 'smithy-client/plugins/response_target'

module Smithy
  module Client
    module Plugins
      describe ResponseTarget do
        let(:client_class) do
          client_class = ClientHelper.sample_service.const_get(:Client)
          client_class.clear_plugins
          client_class.add_plugin(ResponseTarget)
          client_class.add_plugin(DummySendPlugin)
          client_class
        end

        let(:client) { client_class.new }

        before do
          @tempfile = Tempfile.new('response-target')
        end

        after do
          @tempfile.close
        end

        context 'Block target' do
          it 'streams data' do
            data = []
            expected = client.config.response_body
            proc = proc { |chunk| data << chunk }
            client.operation({}, target: proc)
            expect(data).to eq([expected])
          end

          it 'counts the bytes yielded' do
            proc = proc { |chunk| } # empty
            output = client.operation({}, target: proc)
            expected = client.config.response_body.size
            expect(output.context.response.body.size).to eq(expected)
          end

          it 'does not buffer the response chunks' do
            proc = proc { |_chunk| } # empty
            output = client.operation({}, target: proc)
            body = output.context.response.body
            expect(body.read).to eq('')
            expect(body).not_to respond_to(:truncate)
          end

          it 'passes the headers to the block' do
            headers = nil
            proc = proc { |_chunk, header| headers = header }
            client.operation({}, target: proc)
            expect(headers).to be_an_instance_of(HTTP::Headers)
          end
        end

        context 'String path target' do
          let(:target) { @tempfile.path }

          it 'writes to the file name' do
            client.operation({}, target: target)
            expected = client.config.response_body
            expect(File.read(@tempfile.path)).to eq(expected)
          end

          it 'closes the file before returning the response' do
            output = client.operation({}, target: target)
            expect(output.context.response.body).to be_closed
          end

          it 'does not write error messages to the target' do
            error = StandardError.new('error')
            client = client_class.new(response_error: error)
            output = client.operation({}, target: target)
            expect(output.context.response.body.read).to eq('')
            expect { File.unlink(@tempfile.path) }.to raise_error(Errno::ENOENT)
          end
        end

        context 'String path target' do
          let(:target) { Pathname.new(@tempfile.path) }

          it 'writes to the file name' do
            client.operation({}, target: target)
            expected = client.config.response_body
            expect(File.read(@tempfile.path)).to eq(expected)
          end

          it 'closes the file before returning the response' do
            output = client.operation({}, target: target)
            expect(output.context.response.body).to be_closed
          end

          it 'does not write error messages to the target' do
            error = StandardError.new('error')
            client = client_class.new(response_error: error)
            output = client.operation({}, target: target)
            expect(output.context.response.body.read).to eq('')
            expect { File.unlink(@tempfile.path) }.to raise_error(Errno::ENOENT)
          end
        end

        context 'StringIO target' do
          let(:target) { StringIO.new(String.new) }

          it 'writes to the given object' do
            client.operation({}, target: target)
            expected = client.config.response_body
            expect(target.string).to eq(expected)
          end
        end

        context 'File target' do
          let(:target) { @tempfile }

          it 'writes to the file' do
            client.operation({}, target: target)
            expected = client.config.response_body
            expect(File.read(@tempfile.path)).to eq(expected)
          end

          it 'does not unlink the file' do
            error = StandardError.new('error')
            client = client_class.new(response_error: error)
            client.operation({}, target: target)
            expect(File.unlink(@tempfile.path)).to eq(1)
          end
        end
      end
    end
  end
end
