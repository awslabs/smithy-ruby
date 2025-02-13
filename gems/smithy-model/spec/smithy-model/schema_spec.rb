# frozen_string_literal: true

module Smithy
  module Model
    describe Schema do
      subject { Schema.new }
      let(:operation_shape) { Shapes::OperationShape.new }
      let(:operation_name) { :some_operation }

      it 'is enumerable' do
        expect(subject).to be_kind_of(Enumerable)
      end

      describe '#initialize' do
        it 'yields itself' do
          yielded = nil
          subject = Schema.new { |schema| yielded = schema }
          expect(yielded).to be(subject)
        end

        it 'defaults service to nil' do
          expect(subject.service).to be(nil)
        end

        it 'defaults operations to empty hash' do
          expect(subject.operations).to be_empty
        end
      end

      describe '#add_operations' do
        it 'adds an operation' do
          subject.add_operation(operation_name, operation_shape)
          expect(subject.operations[operation_name]).to be(operation_shape)
        end
      end

      describe '#each' do
        it 'enumerates over operations' do
          subject.add_operation(operation_name, operation_shape)
          expect { |b| subject.each(&b) }
            .to yield_successive_args([operation_name, operation_shape])
        end
      end

      describe '#inspect' do
        it 'returns the class name' do
          expect(subject.inspect)
            .to eq('#<Smithy::Model::Schema>')
        end
      end

      describe '#operation' do
        it 'raises an ArgumentError for unknown operations' do
          expect do
            subject.operation(:unknown)
          end.to raise_error(ArgumentError, 'unknown operation :unknown')
        end

        it 'returns the operation' do
          subject.add_operation(operation_name, operation_shape)
          expect(subject.operation(operation_name)).to be(operation_shape)
        end
      end

      describe '#operation_names' do
        it 'defaults to an empty array' do
          expect(subject.operation_names).to eq([])
        end

        it 'provides operation names' do
          subject.add_operation(operation_name, operation_shape)
          subject.add_operation(:foo, Shapes::OperationShape.new)
          expect(subject.operation_names)
            .to eq([operation_name, :foo])
        end
      end
    end
  end
end
