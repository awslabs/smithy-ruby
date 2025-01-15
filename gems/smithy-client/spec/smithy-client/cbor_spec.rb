# frozen_string_literal: true

module Smithy
  module Client
    describe CBOR do
      context 'decode success tests' do
        file = File.expand_path('cbor/decode-success-tests.json', __dir__)
        test_cases = ::JSON.load_file(file)

        def expected_value(expect)
          raise 'invalid test case' if expect.keys.size != 1

          case expect.keys.first
          when 'uint' then expect['uint']
          when 'negint' then expect['negint']
          when 'bytestring' then expect['bytestring'].pack('c*')
          when 'string' then expect['string']
          when 'list'
            expect['list'].map { |item| expected_value(item) }
          when 'map'
            expect['map'].transform_values do |value|
              expected_value(value)
            end
          when 'tag'
            value = expected_value(expect['tag']['value'])
            CBOR::Tagged.new(tag: expect['tag']['id'], value: value)
          when 'bool' then expect['bool']
          when 'null' then nil
          when 'undefined' then :undefined
          when 'float32' then [expect['float32']].pack('L').unpack1('f')
          when 'float64' then [expect['float64']].pack('Q').unpack1('d')
          else
            raise "unexpected expect value: #{expect}"
          end
        end

        def assert(actual, expected)
          case expected
          when Array
            expected.each_with_index do |item, i|
              assert(actual[i], item)
            end
          when Hash
            expected.each do |key, value|
              assert(actual[key], value)
            end
          when Float
            expect(actual.nan?).to be true if expected.nan?
          when CBOR::Tagged
            expect(actual.tag).to eq(expected.tag)
            expect(actual.value).to eq(expected.value)
          else
            expect(actual).to eq(expected)
          end
        end

        test_cases.each do |test_case|
          it "passes #{test_case['description']}" do
            input = [test_case['input']].pack('H*')
            actual = CBOR.decode(input)
            expected = expected_value(test_case['expect'])
            assert(actual, expected)
          end
        end
      end

      context 'decode error tests' do
        file = File.expand_path('cbor/decode-error-tests.json', __dir__)
        test_cases = ::JSON.load_file(file)

        test_cases.each do |test_case|
          it "passes #{test_case['description']}" do
            input = [test_case['input']].pack('H*')

            expect { CBOR.decode(input) }
              .to raise_error(CBOR::Error)
          end
        end
      end

      context 'encode/decode pair tests' do
        it 'encodes and decodes a complex ruby object' do
          h = {
            'a' => [1, 2, 3],
            'b' => Time.parse('2000-01-01')
          }
          expect(CBOR.decode(CBOR.encode(h))).to eq(h)
        end
      end
    end
  end
end
