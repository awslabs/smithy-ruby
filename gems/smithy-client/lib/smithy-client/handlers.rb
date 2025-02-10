# frozen_string_literal: true

module Smithy
  module Client
    # A collection of generic handlers that are used by Smithy Clients.
    module Handlers
      # @api private
      class Build < Handler
        def call(context)
          context.config.protocol.build_request(context)
          @handler.call(context)
        end
      end

      # @api private
      class Parse < Handler
        def call(context)
          resp = @handler.call(context)
          context.config.protocol.parse_response(context)
          resp
        end
      end

      # @api private
      class Error < Handler
        def call(context)
          @handler.call(context).on(300..599) do |response|
            context.config.protocol.parse_error(context, response)
          end
        end
      end
    end
  end
end
