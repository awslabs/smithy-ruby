# frozen_string_literal: true

require_relative 'spec_helper'

module WhiteLabel
  describe Config do
    describe '#build' do
      it 'sets member values with defaults' do
        config_keys = {
          adaptive_retry_wait_to_fill: false,
          disable_host_prefix: true,
          endpoint: 'test',
          http_wire_trace: true,
          log_level: :debug,
          # Logger should exist with log level
          max_attempts: 0,
          retry_mode: 'adaptive',
          stub_responses: false,
          validate_input: false
        }

        config = Config.new(**config_keys)

        config_keys.each do |key, value|
          expect(config.send(key)).to eq(value)
        end

        expect(config.logger).to be_a(Logger)
        expect(config.logger.debug?).to be true
      end

      it 'validates types' do
        expect { Config.new(logger: 'foo') }
          .to raise_error(ArgumentError, /options\[:logger\]/)
      end
    end
  end
end
