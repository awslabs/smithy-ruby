# frozen_string_literal: true

require 'smithy-client/plugins/logging'
require 'smithy-client/plugins/net_http'
require 'smithy-client/plugins/param_converter'
require 'smithy-client/plugins/param_validator'
require 'smithy-client/plugins/raise_response_errors'
require 'smithy-client/plugins/response_target'

module Smithy
  module Welds
    # Provides default plugins.
    class Plugins < Weld
      def for?(_service)
        say_status :insert, 'Adding default plugins', @plan.quiet
        true
      end

      def plugins
        {
          Smithy::Client::Plugins::Logging => {
            require_path: 'smithy-client/plugins/logging'
          },
          Smithy::Client::Plugins::NetHTTP => {
            require_path: 'smithy-client/plugins/net_http'
          },
          Smithy::Client::Plugins::ParamConverter => {
            require_path: 'smithy-client/plugins/param_converter'
          },
          Smithy::Client::Plugins::ParamValidator => {
            require_path: 'smithy-client/plugins/param_validator'
          },
          Smithy::Client::Plugins::RaiseResponseErrors => {
            require_path: 'smithy-client/plugins/raise_response_errors'
          },
          Smithy::Client::Plugins::ResponseTarget => {
            require_path: 'smithy-client/plugins/response_target'
          }
        }
      end
    end
  end
end
