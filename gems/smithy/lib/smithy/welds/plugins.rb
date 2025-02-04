# frozen_string_literal: true

module Smithy
  module Welds
    # Provides default plugins.
    class Plugins < Weld
      def for?(_service)
        say_status :insert, 'Adding default plugins', :yellow
        true
      end

      def plugins
        {
          'Smithy::Client::Plugins::Logging' => {
            path: 'smithy-client/plugins/logging',
            relative_path: true,
            require_path: 'smithy-client/plugins/logging'
          },
          'Smithy::Client::Plugins::RaiseResponseErrors' => {
            path: 'smithy-client/plugins/raise_response_errors',
            relative_path: true,
            require_path: 'smithy-client/plugins/raise_response_errors'
          },
          'Smithy::Client::Plugins::ResponseTarget' => {
            path: 'smithy-client/plugins/response_target',
            relative_path: true,
            require_path: 'smithy-client/plugins/response_target'
          },
          'Smithy::Client::Plugins::NetHTTP' => {
            path: 'smithy-client/plugins/net_http',
            relative_path: true,
            require_path: 'smithy-client/plugins/net_http'
          }
        }
      end
    end
  end
end
