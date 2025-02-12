# frozen_string_literal: true

module Smithy
  module Client
    module Plugins
      # @api private
      class ParamConverter < Plugin
        option(
          :convert_params,
          default: true,
          doc_type: 'Boolean',
          docstring: <<~DOCS)
            When `true`, request parameters are coerced into the required types.
          DOCS

        def add_handlers(handlers, config)
          handlers.add(Handler, step: :initialize) if config.convert_params
        end

        # @api private
        class Handler < Client::Handler
          def call(context)
            converter = Client::ParamConverter.new(context.operation.input)
            context.params = converter.convert(context.params)
            context.response.on_done { converter.close_opened_files }
            @handler.call(context)
          end
        end
      end
    end
  end
end
