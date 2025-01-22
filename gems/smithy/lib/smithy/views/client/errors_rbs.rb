# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class ErrorsRbs < Errors
        attr_reader :model
      end
    end
  end
end
