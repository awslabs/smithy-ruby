# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class ProtocolPlugin < View
        def initialize(plan)
          @plan = plan
          @model = plan.model
          super()
        end

        attr_reader :plan

        def module_name
          @plan.module_name
        end

        def protocol_name
          raise ArgumentError, 'Invalid protocol' if (protocol = resolve_protocol).nil?

          protocol
        end

        private

        SUPPORTED_PROTOCOLS = {
          'smithy.protocols#rpcv2Cbor' => 'RPCV2'
        }.freeze

        # smithy.protocols#rpcv2Cbor
        def resolve_protocol
          protocol = @plan
                     .service
                     .values
                     .first['traits']
                     .find { |k, _v| k.start_with?('smithy.protocols') }
                     &.first
          SUPPORTED_PROTOCOLS[protocol]
        end
      end
    end
  end
end
