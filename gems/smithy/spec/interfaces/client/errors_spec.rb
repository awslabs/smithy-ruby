# frozen_string_literal: true

describe 'Client: Errors', rbs_test: true do
  ['generated client gem', 'generated client from source code'].each do |context|
    next if ENV['SMITHY_RUBY_RBS_TEST'] && context != 'generated client gem'

    context context do
      include_context 'generated client gem', 'Errors'

      it 'generates an errors module' do
        expect(Errors::Errors).to be_a(Module)
      end

      it 'generates client errors' do
        expect(defined?(Errors::Errors::ClientError)).to_not be_nil
      end

      it 'generates client retryable errors' do
        error = Errors::Errors::ClientRetryableError.new(nil, nil)
        expect(error.retryable?).to be(true)
      end

      it 'generates client throttling errors' do
        error = Errors::Errors::ClientThrottlingError.new(nil, nil)
        expect(error.retryable?).to be(true)
        expect(error.throttling?).to be(true)
      end

      it 'generates server errors' do
        expect(defined?(Errors::Errors::ServerError)).to_not be_nil
      end

      it 'generates server retryable errors' do
        error = Errors::Errors::ServerRetryableError.new(nil, nil)
        expect(error.retryable?).to be(true)
      end

      it 'generates server throttling errors' do
        error = Errors::Errors::ServerThrottlingError.new(nil, nil)
        expect(error.retryable?).to be(true)
        expect(error.throttling?).to be(true)
      end

      it 'generates errors from the service shape' do
        expect(defined?(Errors::Errors::ServiceError)).to_not be_nil
      end

      it 'generates errors with messages from data' do
        data = Errors::Types::ServiceError.new(message: 'message')
        error = Errors::Errors::ServiceError.new(nil, nil, data)
        expect(error.message).to eq('message')
        expect { raise error }.to raise_error(Errors::Errors::ServiceError, 'message')
      end

      it 'allows overriding the message' do
        data = Errors::Types::ServiceError.new(message: 'message')
        error = Errors::Errors::ServiceError.new(nil, 'new message', data)
        expect(error.message).to eq('new message')
        expect { raise error }.to raise_error(Errors::Errors::ServiceError, 'new message')
      end

      it 'can return data members' do
        structure = Errors::Types::Structure.new(value: 'foo')
        data = Errors::Types::ServiceError.new(structure: structure)
        error = Errors::Errors::ServiceError.new(nil, nil, data)
        expect(error.data.structure.value).to eq('foo')
      end

      it 'generates a dynamic error class' do
        expect(defined?(Errors::Errors::DynamicError)).to be nil
        new_error = Errors::Errors::DynamicError.new(nil, nil)
        expect(new_error).to be_a(Smithy::Client::Errors::ServiceError)
      end

      it 'generates documentation for error classes' do
        errors_file = File.join(@plan.destination_root, 'lib', 'errors', 'errors.rb')
        expected = <<~DOC
          This is a service error.
          It is raised sometimes.
        DOC
        expect(expected).to be_in_documentation(errors_file, 'Errors::Errors::ServiceError')
      end

      it 'generates documentation for error members' do
        errors_file = File.join(@plan.destination_root, 'lib', 'errors', 'errors.rb')
        expected = <<~DOC
          This is a structure in a service error.
          It sometimes has data.
        DOC
        expect(expected).to be_in_documentation(errors_file, 'Errors::Errors::ServiceError', 'structure')
      end
    end
  end
end
