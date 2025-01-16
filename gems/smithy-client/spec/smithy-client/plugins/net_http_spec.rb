# frozen_string_literal: true

require 'smithy-client/plugins/net_http'

module Smithy
  module Client
    module Plugins
      describe NetHTTP do
        let(:client_class) do
          schema = Schema.new
          schema.add_operation(:operation_name, Shapes::OperationShape.new)
          client_class = Class.new(Client::Base)
          client_class.schema = schema
          client_class.clear_plugins
          client_class.add_plugin(NetHTTP)
          client_class
        end

        it 'adds net http options' do
          options = {
            # Connections
            http_continue_timeout: 1,
            http_keep_alive_timeout: 1,
            http_open_timeout: 1,
            http_read_timeout: 1,
            http_ssl_timeout: 1,
            http_write_timeout: 1,
            # Security
            http_ca_file: 'file',
            http_ca_path: 'path/to/files',
            http_cert: 'cert',
            http_cert_store: 'store',
            http_key: 'key',
            http_verify_mode: OpenSSL::SSL::VERIFY_NONE,
            # Debugging
            http_debug_output: true,
            # Proxies
            http_proxy: 'http://proxy.com:123'
          }
          client_class.new(options)
        end
      end
    end
  end
end
