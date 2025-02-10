# frozen_string_literal: true

module Smithy
  module Client
    # A collection of generic handlers that are used by Smithy Clients.
    # @api private
    module Handlers
      # Generic build handler to build request based on protocol
      class Build < Handler
        def call(context)
          context.config.protocol.build(context)
          @handler.call(context)
        end
      end

      # Generic parse handler to parse response based on protocol
      class Parse < Handler
        def call(context)
          resp = @handler.call(context)
          context.config.protocol.parse(context)
          resp
        end
      end

      # Generic error handler to parse error based on protocol
      class Error < Handler
        def call(context)
          @handler.call(context).on(300..599) do |response|
            context.config.protocol.error(context, response)
          end
        end
      end
    end
  end
end
