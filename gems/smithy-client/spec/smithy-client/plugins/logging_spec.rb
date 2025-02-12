# frozen_string_literal: true

require 'smithy-client/plugins/logging'

module Smithy
  module Client
    module Plugins
      describe Logging do
        let(:client_class) do
          client_class = ClientHelper.sample_service.const_get(:Client)
          client_class.clear_plugins
          client_class.add_plugin(Logging)
          client_class.add_plugin(DummySendPlugin)
          client_class
        end

        let(:logger) { Logger.new(IO::NULL) }
        let(:log_level) { :info }

        it 'adds a :logger option to config' do
          client = client_class.new(logger: logger)
          expect(client.config.logger).to be(logger)
        end

        it 'adds a :log_level option to config' do
          client = client_class.new(log_level: log_level)
          expect(client.config.log_level).to be(log_level)
        end

        it 'does not add the handler unless a logger is provided' do
          client = client_class.new
          expect(client.handlers).not_to include(Logging::Handler)
        end

        it 'adds the handler when a logger is provided' do
          client = client_class.new(logger: logger)
          expect(client.handlers).to include(Logging::Handler)
        end

        it 'logs the output to the log level' do
          expect(logger).to receive(log_level).with(instance_of(Output))
          client = client_class.new(logger: logger, log_level: log_level)
          client.send(:build_input, :operation, {}).send_request
        end

        it 'sets start and end times in the context' do
          client = client_class.new(logger: logger, log_level: log_level)
          out = client.send(:build_input, :operation, {}).send_request
          expect(out.context[:logging_started_at]).to be_kind_of(Time)
          expect(out.context[:logging_completed_at]).to be_kind_of(Time)
          expect(out.context[:logging_started_at]).to be <= out.context[:logging_completed_at]
        end
      end
    end
  end
end
