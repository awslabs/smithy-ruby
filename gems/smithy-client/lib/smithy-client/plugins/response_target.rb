# frozen_string_literal: true

require 'pathname'

module Smithy
  module Client
    module Plugins
      # @api private
      class ResponseTarget < Plugin
        # This handler is responsible for replacing the response body IO
        # object with custom targets, such as a block, or a file. It is important
        # to not write data to the custom target in the case of a non-success
        # response. We do not want to write an XML error message to someone's
        # file.
        class Handler < Client::Handler
          def call(context)
            target = context[:response_target]
            add_event_listeners(context.response, target) if target
            @handler.call(context)
          end

          private

          def add_event_listeners(response, target)
            add_header_listener(response, target)
            add_success_listener(response)
            add_error_listener(response)
          end

          def add_header_listener(response, target)
            response.on_headers(200..299) do
              # In a fresh response, the body will be a StringIO. However, when a request
              # is retried we may have an existing ManagedFile or BlockIO,
              # and those should be reused.
              response.body = io(target, response.headers) if response.body.is_a?(StringIO)
            end
          end

          def add_success_listener(response)
            response.on_success(200..299) do
              body = response.body
              body.close if body.is_a?(ManagedFile) && body.open?
            end
          end

          def add_error_listener(response)
            response.on_error do
              body = response.body
              # When using a File response_target, we do not want to write
              # error messages to the file. So set the body to a new StringIO
              if body.is_a?(ManagedFile)
                File.unlink(body)
                response.body = StringIO.new
              end
            end
          end

          def io(target, headers)
            case target
            when Proc then BlockIO.new(headers, &target)
            when String, Pathname then ManagedFile.new(target, 'w+b')
            else target
            end
          end
        end

        handler(Handler, step: :initialize, priority: 90)
      end
    end
  end
end
