# frozen_string_literal: true

module Smithy
  module Client
    describe HandlerContext do
      subject(:context) { HandlerContext.new }

      describe '#operation_name' do
        it 'defaults to nil' do
          expect(subject.operation_name).to be(nil)
        end

        it 'can be set in the constructor' do
          context = HandlerContext.new(operation_name: 'operation_name')
          expect(context.operation_name).to eq('operation_name')
        end
      end

      describe '#operation' do
        it 'defaults to nil' do
          expect(subject.operation).to be(nil)
        end

        it 'can be set in the constructor' do
          operation = Operation.new
          context = HandlerContext.new(operation: operation)
          expect(context.operation).to be(operation)
        end
      end

      describe '#client' do
        it 'defaults to nil' do
          expect(subject.client).to be(nil)
        end

        it 'can be set in the constructor' do
          client = double('client')
          context = HandlerContext.new(client: client)
          expect(context.client).to be(client)
        end
      end

      describe '#params' do
        it 'defaults to an empty hash' do
          expect(subject.params).to eq({})
        end

        it 'can be set in the constructor' do
          params = { foo: 'bar' }
          context = HandlerContext.new(params: params)
          expect(context.params).to eq(params)
        end
      end

      describe '#config' do
        it 'defaults to nil' do
          expect(subject.config).to be(nil)
        end

        it 'can be set in the constructor' do
          config = Configuration.new
          context = HandlerContext.new(config: config)
          expect(context.config).to be(config)
        end
      end

      describe '#request' do
        it 'defaults to HTTP::Request' do
          expect(subject.request).to be_a(HTTP::Request)
        end

        it 'can be set in the constructor' do
          request = double('request')
          context = HandlerContext.new(request: request)
          expect(context.request).to be(request)
        end
      end

      describe '#response' do
        it 'defaults to HTTP::Response' do
          expect(subject.response).to be_a(HTTP::Response)
        end

        it 'can be set in the constructor' do
          response = double('response')
          context = HandlerContext.new(response: response)
          expect(context.response).to be(response)
        end
      end

      context 'metadata' do
        it 'returns nil for non-set keys' do
          expect(subject[:color]).to be(nil)
        end

        it 'can be set via #[]=' do
          subject[:color] = 'red'
          expect(subject[:color]).to eq('red')
        end
      end
    end
  end
end
