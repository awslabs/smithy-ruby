# frozen_string_literal: true

module Smithy
  module Client
    module Plugins
      # @api private
      class ParamValidator < Plugin
        option(
          :validate_params,
          default: true,
          doc_type: 'Boolean',
          docstring: <<~DOCS)
            When `true`, request parameters are validated before sending the request.
          DOCS

        def add_handlers(handlers, config)
          handlers.add(Handler, step: :validate) if config.validate_params
        end

        # @api private
        class Handler < Client::Handler
          def call(context)
            Client::ParamValidator.validate!(context.operation.input, context.params)
            @handler.call(context)
          end
        end
      end
    end
  end
end

