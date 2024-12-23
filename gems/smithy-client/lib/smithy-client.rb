# frozen_string_literal: true

# client

require_relative 'smithy-client/configuration'
require_relative 'smithy-client/handler'
require_relative 'smithy-client/handler_context'
require_relative 'smithy-client/handler_builder'
require_relative 'smithy-client/handler_list'
require_relative 'smithy-client/handler_list_entry'
require_relative 'smithy-client/networking_error'
require_relative 'smithy-client/plugin'
require_relative 'smithy-client/plugin_list'
require_relative 'smithy-client/input'
require_relative 'smithy-client/output'
require_relative 'smithy-client/response'
require_relative 'smithy-client/request'

# client http

require_relative 'smithy-client/http/field'
require_relative 'smithy-client/http/fields'
require_relative 'smithy-client/http/response'
require_relative 'smithy-client/http/request'

require_relative 'smithy-client/net_http/connection_pool'
require_relative 'smithy-client/net_http/handler'

# plugins

require_relative 'smithy-client/plugins/logging'
require_relative 'smithy-client/plugins/raise_response_errors'
require_relative 'smithy-client/plugins/net_http'

# model

require_relative 'smithy-client/api'
require_relative 'smithy-client/base'
require_relative 'smithy-client/errors'
require_relative 'smithy-client/operation'
require_relative 'smithy-client/structure'

# endpoints
require_relative 'smithy-client/endpoint_rules'

module Smithy
  # Base module for a generated Smithy gem.
  module Client
    VERSION = File.read(File.expand_path('../VERSION', __dir__)).strip
  end
end
