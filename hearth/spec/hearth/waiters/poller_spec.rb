# frozen_string_literal: true

module Hearth
  module Waiters
    describe Poller do
      subject do
        Poller.new(
          operation_name: :test_operation,
          acceptors: acceptors
        )
      end

      let(:client) { double('client') }
      let(:input_output_middleware) { double('input_output_middleware') }

      let(:test_operation_struct) do
        Struct.new(
          :string,
          :boolean,
          :all_string,
          :any_string,
          keyword_init: true
        )
      end
      let(:struct) do
        test_operation_struct.new(
          string: 'peccy',
          boolean: true,
          all_string: %w[foo foo],
          any_string: %w[bar foo]
        )
      end

      let(:error) do
        Hearth::ApiError.new(
          error_code: 'SomeError',
          message: 'error'
        )
      end

      before do
        expect(Hearth::MiddlewareBuilder).to receive(:before_send)
          .and_wrap_original do |_middleware, handler|
            # middleware captures input for inputOutput matcher
            handler.call(struct, {})
            # return a mocked middleware
            input_output_middleware
          end
      end

      describe '#call' do
        context 'no matchers' do
          let(:acceptors) { [] }

          context 'client error' do
            it 'returns error state with error' do
              expect(client).to receive(:test_operation)
                .with({}, { middleware: input_output_middleware })
                .and_raise(error)

              expect(subject.call(client, {}, {})).to eq [:error, error]
            end
          end

          context 'client response' do
            it 'returns retry state with response' do
              expect(client).to receive(:test_operation)
                .with({}, { middleware: input_output_middleware })
                .and_return(struct)

              expect(subject.call(client, {}, {})).to eq [:retry, struct]
            end
          end
        end

        context 'success matchers' do
          let(:acceptors) do
            [
              { state: 'success', matcher: { success: true } }
            ]
          end

          it 'can match success' do
            expect(client).to receive(:test_operation)
              .with({}, { middleware: input_output_middleware })
              .and_return(struct)

            expect(subject.call(client, {}, {})).to eq [:success, struct]
          end
        end

        context 'error type matchers' do
          let(:acceptors) do
            [
              { state: 'retry', matcher: { errorType: 'SomeError' } }
            ]
          end

          it 'can match error types' do
            expect(client).to receive(:test_operation)
              .with({}, { middleware: input_output_middleware })
              .and_raise(error)

            expect(subject.call(client, {}, {})).to eq [:retry, error]
          end
        end

        context 'input output matchers' do
          context 'string equals' do
            let(:acceptors) do
              [
                {
                  state: 'success',
                  matcher: {
                    inputOutput: {
                      path: 'input.string',
                      expected: 'peccy',
                      comparator: 'stringEquals'
                    }
                  }
                }
              ]
            end

            it 'can match string equals' do
              expect(client).to receive(:test_operation)
                .with({}, { middleware: input_output_middleware })
                .and_return(struct)

              expect(subject.call(client, {}, {})).to eq [:success, struct]
            end
          end

          context 'boolean equals' do
            let(:acceptors) do
              [
                {
                  state: 'success',
                  matcher: {
                    inputOutput: {
                      path: 'length(input.string) == length(output.string)',
                      expected: 'true',
                      comparator: 'booleanEquals'
                    }
                  }
                }
              ]
            end

            it 'can match boolean equals' do
              expect(client).to receive(:test_operation)
                .with({}, { middleware: input_output_middleware })
                .and_return(struct)

              expect(subject.call(client, {}, {})).to eq [:success, struct]
            end
          end

          context 'all string equals' do
            let(:acceptors) do
              [
                {
                  state: 'success',
                  matcher: {
                    inputOutput: {
                      path: 'input.all_string',
                      expected: 'foo',
                      comparator: 'allStringEquals'
                    }
                  }
                }
              ]
            end

            it 'can match boolean equals' do
              expect(client).to receive(:test_operation)
                .with({}, { middleware: input_output_middleware })
                .and_return(struct)

              expect(subject.call(client, {}, {})).to eq [:success, struct]
            end
          end

          context 'any string equals' do
            let(:acceptors) do
              [
                {
                  state: 'success',
                  matcher: {
                    inputOutput: {
                      path: 'input.any_string',
                      expected: 'bar',
                      comparator: 'anyStringEquals'
                    }
                  }
                }
              ]
            end

            it 'can match boolean equals' do
              expect(client).to receive(:test_operation)
                .with({}, { middleware: input_output_middleware })
                .and_return(struct)

              expect(subject.call(client, {}, {})).to eq [:success, struct]
            end
          end
        end

        context 'output matchers' do
          context 'string equals' do
            let(:acceptors) do
              [
                {
                  state: 'success',
                  matcher: {
                    output: {
                      path: 'string',
                      expected: 'peccy',
                      comparator: 'stringEquals'
                    }
                  }
                }
              ]
            end

            it 'can match string equals' do
              expect(client).to receive(:test_operation)
                .with({}, { middleware: input_output_middleware })
                .and_return(struct)

              expect(subject.call(client, {}, {})).to eq [:success, struct]
            end
          end

          context 'boolean equals' do
            let(:acceptors) do
              [
                {
                  state: 'success',
                  matcher: {
                    output: {
                      path: 'boolean',
                      expected: 'true',
                      comparator: 'booleanEquals'
                    }
                  }
                }
              ]
            end

            it 'can match boolean equals' do
              expect(client).to receive(:test_operation)
                .with({}, { middleware: input_output_middleware })
                .and_return(struct)

              expect(subject.call(client, {}, {})).to eq [:success, struct]
            end
          end

          context 'all string equals' do
            let(:acceptors) do
              [
                {
                  state: 'success',
                  matcher: {
                    output: {
                      path: 'all_string',
                      expected: 'foo',
                      comparator: 'allStringEquals'
                    }
                  }
                }
              ]
            end

            it 'can match boolean equals' do
              expect(client).to receive(:test_operation)
                .with({}, { middleware: input_output_middleware })
                .and_return(struct)

              expect(subject.call(client, {}, {})).to eq [:success, struct]
            end
          end

          context 'any string equals' do
            let(:acceptors) do
              [
                {
                  state: 'success',
                  matcher: {
                    output: {
                      path: 'any_string',
                      expected: 'bar',
                      comparator: 'anyStringEquals'
                    }
                  }
                }
              ]
            end

            it 'can match boolean equals' do
              expect(client).to receive(:test_operation)
                .with({}, { middleware: input_output_middleware })
                .and_return(struct)

              expect(subject.call(client, {}, {})).to eq [:success, struct]
            end
          end
        end

        context 'multiple matchers' do
          let(:acceptors) do
            [
              {
                state: 'failure',
                matcher: {
                  output: {
                    path: 'any_string',
                    expected: 'should not match',
                    comparator: 'anyStringEquals'
                  }
                }
              },
              {
                state: 'success',
                matcher: {
                  output: {
                    path: 'string',
                    expected: 'peccy',
                    comparator: 'stringEquals'
                  }
                }
              }
            ]
          end

          it 'iterates all matchers' do
            expect(client).to receive(:test_operation)
              .with({}, { middleware: input_output_middleware })
              .and_return(struct)

            expect(subject.call(client, {}, {})).to eq [:success, struct]
          end
        end
      end
    end
  end
end
