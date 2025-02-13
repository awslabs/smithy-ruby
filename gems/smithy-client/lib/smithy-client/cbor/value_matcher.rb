# frozen_string_literal: true

require 'rspec/expectations'

def expected_nan?(expected)
  expected == 'NaN' || expected.nan?
end

def expected_infinite?(expected)
  expected == 'Infinity' || expected == '-Infinity' || expected.infinite?
end

# Provides an rspec matcher for CBOR encoded values
# rubocop:disable Metrics/BlockLength
RSpec::Matchers.define :match_cbor do |expected|
  match do |actual|
    # identical values don't need more comparison
    return true if actual == expected

    expect(actual.class).to eq(expected.class)

    def match_hash(actual, expected)
      expected.each do |key, value|
        expect(actual).to include(key)
        match_value(actual[key], value)
      end

      actual.each_key do |key|
        expect(expected).to include(key)
      end
    end

    def match_array(actual, expected)
      actual.each_with_index do |value, index|
        match_value(value, expected[index])
      end
    end

    def match_float(actual, expected)
      return if actual.nan? && expected_nan?(expected)
      return if actual.infinite? && expected_infinite?(expected)

      expect(actual).to be_within(0.0001).of(expected)
    end

    def match_value(actual, expected)
      case actual
      when Hash
        match_hash(actual, expected)
      when Array
        match_array(actual, expected)
      when Float
        match_float(actual, expected)
      when Time
        expect(actual.utc.iso8601).to eq(expected.utc.iso8601)
      else
        expect(actual).to eq(expected)
      end
    end

    match_value(actual, expected)
  end

  diffable
end
# rubocop:enable Metrics/BlockLength
