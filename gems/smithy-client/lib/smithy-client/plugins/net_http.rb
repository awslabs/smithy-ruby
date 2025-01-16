# frozen_string_literal: true

require 'smithy-client/net_http/handler'

module Smithy
  module Client
    module Plugins
      # @api private
      class NetHTTP < Plugin
        ## Connections

        option(
          :http_continue_timeout,
          default: nil,
          doc_type: Numeric,
          docstring: <<~DOCS)
            Sets the continue timeout value, which is the number of seconds to wait for an
            expected 100 Continue response. If the HTTP object does not receive a response
            in this many seconds it sends the request body. Defaults to `nil` which uses the
            Net::HTTP default value.
            @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-continue_timeout
          DOCS

        option(
          :http_keep_alive_timeout,
          default: nil,
          doc_type: Numeric,
          docstring: <<~DOCS)
            The number of seconds to keep the connection open after a request is sent. If a
            new request is made during the given interval, the still-open connection is used;
            otherwise the connection will have been closed and a new connection is opened.
            Defaults to `nil` which uses the Net::HTTP default value.
            @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-keep_alive_timeout
          DOCS

        option(
          :http_open_timeout,
          default: nil,
          doc_type: Numeric,
          docstring: <<~DOCS)
            The number of seconds to wait for a connection to open. If the connection is not
            made in the given interval, an exception is raised. Defaults to `nil` which uses
            the Net::HTTP default value.
            @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-open_timeout
          DOCS

        option(
          :http_read_timeout,
          default: nil,
          doc_type: Numeric,
          docstring: <<~DOCS)
            The number of seconds to wait for one block to be read (via one read(2) call).
            Defaults to `nil` which uses the Net::HTTP default value.
            @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-read_timeout
          DOCS

        option(
          :http_ssl_timeout,
          default: nil,
          doc_type: Numeric,
          docstring: <<~DOCS)
            Sets the SSL timeout seconds. Defaults to `nil` which uses the Net::HTTP default value.
            @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-ssl_timeout
          DOCS

        option(
          :http_write_timeout,
          default: nil,
          doc_type: Numeric,
          docstring: <<~DOCS)
            The number of seconds to wait for one block to be written (via one write(2) call).
            Defaults to `nil` which uses the Net::HTTP default value.
            @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-write_timeout
          DOCS

        ## Security

        option(
          :http_ca_file,
          default: nil,
          doc_type: String,
          docstring: <<~DOCS)
            The path to a CA certification file in PEM format. Defaults to `nil` which uses
            the Net::HTTP default value.
            @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-ca_file
          DOCS

        option(
          :http_ca_path,
          default: nil,
          doc_type: String,
          docstring: <<~DOCS)
            The path of to CA directory containing certification files in PEM format. Defaults to
            `nil` which uses the Net::HTTP default value.
            @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-ca_path
          DOCS

        option(
          :http_cert,
          default: nil,
          doc_type: OpenSSL::X509::Certificate,
          docstring: <<~DOCS)
            Sets the OpenSSL::X509::Certificate object to be used for client certification. Defaults
            to `nil` which uses the Net::HTTP default value.
            @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-cert
          DOCS

        option(
          :http_cert_store,
          default: nil,
          doc_type: OpenSSL::X509::Store,
          docstring: <<~DOCS)
            Sets the OpenSSL::X509::Store to be used for verifying peer certificate. Defaults to
            `nil` which uses the Net::HTTP default value.
            @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-cert_store
          DOCS

        option(
          :http_key,
          default: nil,
          doc_type: 'OpenSSL::PKey::RSA, OpenSSL::PKey::DSA',
          docstring: <<~DOCS)
            Sets the OpenSSL::PKey object to be used for client private key. Defaults to `nil` which
            uses the Net::HTTP default value.
            @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-key
          DOCS

        option(
          :http_verify_mode,
          default: OpenSSL::SSL::VERIFY_PEER,
          doc_type: Integer,
          doc_default: 'OpenSSL::SSL::VERIFY_PEER',
          docstring: <<~DOCS)
            Sets the verify mode for SSL. Defaults to `OpenSSL::SSL::VERIFY_PEER`.
            @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#attribute-i-verify_mode
          DOCS

        ## Debugging

        option(
          :http_debug_output,
          default: false,
          doc_type: 'Boolean',
          docstring: <<~DOCS)
            When `true`, Net::HTTP debug output will be sent to the configured logger.
            @see https://docs.ruby-lang.org/en/master/Net/HTTP.html#method-i-set_debug_output
          DOCS

        ## Proxies

        option(
          :http_proxy,
          default: nil,
          doc_type: 'URI::HTTP, String',
          docstring: <<~DOCS)
            A proxy to send requests through. Formatted like 'http://proxy.com:123'.
          DOCS

        def add_handlers(handlers, _config)
          handlers.add(Smithy::Client::NetHTTP::Handler, step: :send)
        end
      end
    end
  end
end
