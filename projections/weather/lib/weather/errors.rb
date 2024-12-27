# frozen_string_literal: true

# This is generated code!

module Weather
  # When this service returns an error response, the SDK constructs and raises an error.
  # These errors all extend Weather::Errors::ServiceError < {Smithy::Client::Errors::ServiceError}
  #
  # You can rescue all errors using the ServiceError:
  #
  #     begin
  #       # do stuff
  #     rescue Weather::Errors::ServiceError
  #       # rescues all API errors
  #     end
  #
  # ## Request Context
  #
  # ServiceError objects have a {Smithy::Client::Errors::ServiceError#context #context} method
  # that returns information about the request that generated the error.
  # See {Smithy::Client::HandlerContext} for more information.
  #
  # ## Error Classes
  #
  # * {NoSuchResource}
  #
  # Additionally, error classes are dynamically generated for service errors based on the error code
  # if they are not defined above.
  module Errors
    extend Smithy::Client::Errors::DynamicErrors

    # TODO!
    class NoSuchResource < Smithy::Client::Errors::ServiceError
      # @param [Smithy::Client::HandlerContext] context
      # @param [String] message
      # @param [Weather::Types::NoSuchResource] data
      def initialize(context, message, data)
        super(context, message, data)
      end

      def resource_type
        @data[:resource_type]
      end
    end
  end
end
