# frozen_string_literal: true

module Smithy
  module Views
    # @api private
    module Client; end
  end
end

# helper classes

require_relative 'client/endpoint_parameter'
require_relative 'client/operation_examples'
require_relative 'client/request_response_example'

# views

require_relative 'client/client'
require_relative 'client/customizations'
require_relative 'client/endpoint_parameters'
require_relative 'client/endpoint_plugin'
require_relative 'client/endpoint_provider'
require_relative 'client/errors'
require_relative 'client/gemspec'
require_relative 'client/module'
require_relative 'client/rubocop_yml'
require_relative 'client/shapes'
require_relative 'client/endpoint_provider_spec'
require_relative 'client/spec_helper'
require_relative 'client/types'
