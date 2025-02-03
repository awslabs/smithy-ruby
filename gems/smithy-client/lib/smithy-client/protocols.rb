# frozen_string_literal: true

module Smithy
  module Client
    module Protocols
      # Base protocol class that all protocols derived from
      class ProtocolBase
        def initialize(id)
          @id = id
          @service_id = nil
        end

        attr_reader :id

        attr_accessor :service_id

        def build_request(context)
          raise NotImplementedError
        end

        def parse_response(context)
          raise NotImplementedError
        end

        def parse_error
          raise NotImplementedError
        end
      end
    end
  end
end
