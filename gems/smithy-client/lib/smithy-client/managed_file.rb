# frozen_string_literal: true

module Smithy
  module Client
    # This utility class is used to track files opened by Smithy::Client.
    # @api private
    class ManagedFile < File
      # @return [Boolean]
      def open?
        !closed?
      end
    end
  end
end
