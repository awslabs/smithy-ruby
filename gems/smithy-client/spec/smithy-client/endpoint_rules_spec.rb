# frozen_string_literal: true

module Smithy
  module Client
    describe EndpointRules do
      describe EndpointRules::Endpoint do
        describe '#initialize' do
          it 'sets the uri and defaults other values' do
            uri = 'https://example.com'
            endpoint = EndpointRules::Endpoint.new(uri: uri)
            expect(endpoint.uri).to eq(uri)
            expect(endpoint.properties).to eq({})
            expect(endpoint.headers).to eq({})
          end
        end
      end

      describe '.valid_host_label?' do
        it 'returns false for an empty value' do
          expect(EndpointRules.valid_host_label?('', false)).to be false
        end

        it 'returns false for values with spaces' do
          expect(EndpointRules.valid_host_label?('invalid label', false)).to be false
        end

        it 'returns true for a valid host label' do
          expect(EndpointRules.valid_host_label?('valid-label-1', false)).to be true
        end

        it 'returns false for values starting with -' do
          expect(EndpointRules.valid_host_label?('-invalid', false)).to be false
        end

        it 'returns false for values ending with -' do
          expect(EndpointRules.valid_host_label?('invalid-', false)).to be false
        end

        it 'returns true for values starting with a number' do
          expect(EndpointRules.valid_host_label?('1valid', false)).to be true
        end

        it 'returns true for a single valid character' do
          expect(EndpointRules.valid_host_label?('h', false)).to be true
        end

        it 'returns false for 64 characters' do
          expect(EndpointRules.valid_host_label?('h' * 64, false)).to be false
        end

        context 'allow_sub_domains=false' do
          it 'returns false when value has subdomains' do
            expect(EndpointRules.valid_host_label?('a.b', false)).to be false
          end
        end

        context 'allow_sub_domains=true' do
          it 'returns true when value has subdomains' do
            expect(EndpointRules.valid_host_label?('part1.part2', true)).to be true
          end

          it 'returns false for multiple consecutive dots' do
            expect(EndpointRules.valid_host_label?('a..b-', true)).to be false
          end

          it 'returns false for values ending in a dot' do
            expect(EndpointRules.valid_host_label?('a.b.', true)).to be false
          end

          it 'returns false for sub domains starting with a dash' do
            expect(EndpointRules.valid_host_label?('part1.-part2', true)).to be false
          end
        end
      end

      describe '.parse_url' do
        it 'parses a valid url' do
          expect(EndpointRules.parse_url('https://example.com'))
            .to eq(
              'scheme' => 'https',
              'authority' => 'example.com',
              'path' => '',
              'normalizedPath' => '/',
              'isIp' => false
            )
        end

        it 'parses a valid url with port and path' do
          expect(EndpointRules.parse_url('https://example.com:80/foo/bar'))
            .to eq(
              'scheme' => 'https',
              'authority' => 'example.com:80',
              'path' => '/foo/bar',
              'normalizedPath' => '/foo/bar/',
              'isIp' => false
            )
        end

        it 'parses a valid ip4 address' do
          expect(EndpointRules.parse_url('https://127.0.0.1'))
            .to eq(
              'scheme' => 'https',
              'authority' => '127.0.0.1',
              'path' => '',
              'normalizedPath' => '/',
              'isIp' => true
            )
        end

        it 'parses a valid ip6 address' do
          expect(EndpointRules.parse_url('https://[fe80::1]'))
            .to eq(
              'scheme' => 'https',
              'authority' => '[fe80::1]',
              'path' => '',
              'normalizedPath' => '/',
              'isIp' => true
            )
        end

        it 'returns nil for and invalid url' do
          expect(EndpointRules.parse_url(
                   'https://example.com:8443?foo=bar&faz=baz'
                 )).to be_nil
        end
      end

      describe '.substring' do
        it 'returns the substring when the string is long enough' do
          expect(EndpointRules.substring('abcdefg', 0, 4, false)).to eq 'abcd'
        end

        it 'returns the substring when the string is exactly the right length' do
          expect(EndpointRules.substring('abcd', 0, 4, false)).to eq 'abcd'
        end

        it 'returns nil when the string is too short' do
          expect(EndpointRules.substring('abc', 0, 4, false)).to be_nil
        end

        it 'returns the correct string on wide characters' do
          expect(EndpointRules.substring("\ufdfd", 0, 4, false)).to be_nil
        end

        it 'returns nil on non unicode characters' do
          expect(EndpointRules.substring("abcdef\u0080", 0, 4, false)).to be_nil
        end

        it 'returns substring on non printable ascii characters' do
          expect(EndpointRules.substring("\u007Fabcdef", 0, 4, false))
            .to eq "\u007Fabc"
        end

        context 'reverse = true' do
          it 'returns substring from the end when string is long enough' do
            expect(EndpointRules.substring('abcdefg', 0, 4, true)).to eq 'defg'
          end

          it 'returns nil when string is not long enough' do
            expect(EndpointRules.substring('abc', 0, 4, true)).to be_nil
          end
        end

        context 'substring from the middle' do
          it 'returns substring from the middle when string is long enough' do
            expect(EndpointRules.substring('defg', 1, 3, false)).to eq 'ef'
          end
        end
      end

      describe '.uri_encode' do
        it 'returns the string when theres nothing to encode' do
          expect(EndpointRules.uri_encode('abcdefg')).to eq('abcdefg')
        end

        it 'encodes all required ASCII characters' do
          encoded = '%2F%3A%2C%3F%23%5B%5D%7B%7D%7C%40%21%20%24' \
                    '%26%27%28%29%2A%2B%3B%3D%25%3C%3E%22%5E%60%5C'
          expect(EndpointRules.uri_encode("/:,?#[]{}|@! $&'()*+;=%<>\"^`\\"))
            .to eq(encoded)
        end

        it 'does not encode ASCII characters it should not' do
          expect(EndpointRules.uri_encode('0123456789.underscore_dash-Tilda~'))
            .to eq('0123456789.underscore_dash-Tilda~')
        end

        it 'encodes unicode characters' do
          expect(EndpointRules.uri_encode('😹')).to eq('%F0%9F%98%B9')
        end

        it 'correctly encodes all printable ASCII characters' do
          input = " !\"#$%&'()*+,-./0123456789:;<=>?" \
                  '@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`' \
                  'abcdefghijklmnopqrstuvwxyz{|}~'
          encoded = '%20%21%22%23%24%25%26%27%28%29%2A%2B%2C-.' \
                    '%2F0123456789%3A%3B%3C%3D%3E%3F%40ABCDEFGHIJKLMNOPQRSTUV' \
                    'WXYZ%5B%5C%5D%5E_%60abcdefghijklmnopqrstuvwxyz%7B%7C%7D~'
          expect(EndpointRules.uri_encode(input)).to eq(encoded)
        end
      end

      describe '.set?' do
        it 'returns true when the value is set' do
          expect(EndpointRules.set?('value')).to be true
        end

        it 'returns false when the value is nil' do
          expect(EndpointRules.set?(nil)).to be false
        end
      end

      describe '.not' do
        it 'returns true when the value is false' do
          expect(EndpointRules.not(false)).to be true
        end

        it 'returns false when the value is true' do
          expect(EndpointRules.not(true)).to be false
        end
      end

      describe '.attr' do
        let(:array) { [0, 1, 2] }
        let(:object) { { 'thing1' => 'value1', 'nested' => { 'thing2' => 'value2', 'array' => array } } }

        it 'returns the top level value' do
          expect(EndpointRules.attr(object, 'thing1')).to eq('value1')
        end

        it 'returns nested values' do
          expect(EndpointRules.attr(object, 'nested.thing2')).to eq('value2')
        end

        it 'returns top level array value' do
          expect(EndpointRules.attr(array, '[2]')).to eq(2)
        end

        it 'returns nested array value' do
          expect(EndpointRules.attr(object, 'nested.array[2]')).to eq(2)
        end
      end

      describe '.string_equals?' do
        it 'returns true when the strings are equal' do
          expect(EndpointRules.string_equals?('value', 'value')).to be true
        end

        it 'returns false when the strings are not equal' do
          expect(EndpointRules.string_equals?('value', 'other')).to be false
        end
      end

      describe '.boolean_equals?' do
        it 'returns true when the booleans are equal' do
          expect(EndpointRules.boolean_equals?(true, true)).to be true
        end

        it 'returns false when the booleans are not equal' do
          expect(EndpointRules.boolean_equals?(true, false)).to be false
        end
      end
    end
  end
end
