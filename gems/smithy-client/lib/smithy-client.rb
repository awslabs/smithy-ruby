# frozen_string_literal: true

require 'jmespath'

require 'smithy-model'

# client

require_relative 'smithy-client/block_io'
require_relative 'smithy-client/configuration'
require_relative 'smithy-client/endpoint_rules'
require_relative 'smithy-client/errors'
require_relative 'smithy-client/handler'
require_relative 'smithy-client/handler_builder'
require_relative 'smithy-client/handler_context'
require_relative 'smithy-client/handler_list'
require_relative 'smithy-client/handler_list_entry'
require_relative 'smithy-client/managed_file'
require_relative 'smithy-client/networking_error'
require_relative 'smithy-client/param_converter'
require_relative 'smithy-client/param_validator'
require_relative 'smithy-client/plugin'
require_relative 'smithy-client/plugin_list'
require_relative 'smithy-client/input'
require_relative 'smithy-client/output'
require_relative 'smithy-client/base'

# client http

require_relative 'smithy-client/http/headers'
require_relative 'smithy-client/http/response'
require_relative 'smithy-client/http/request'
require_relative 'smithy-client/net_http/connection_pool'
require_relative 'smithy-client/net_http/handler'

# codecs

require_relative 'smithy-client/cbor'
require_relative 'smithy-client/codecs/cbor'

module Smithy
  # Base module for a generated Smithy gem.
  module Client
    VERSION = File.read(File.expand_path('../VERSION', __dir__.to_s)).strip
  end
end
