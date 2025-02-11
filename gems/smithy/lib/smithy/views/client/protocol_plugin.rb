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

        def protocol
          return if default_protocol.nil?

          weld_protocols[default_protocol]
        end

        private

        def service_traits
          @service_traits ||= @plan.service.values.first.fetch('traits', {})
        end

        # TODO: Weld ordering - see Smithy::Welds::Protocols for more info
        def weld_protocols
          @weld_protocols ||= @plan.welds.map(&:protocols).reduce({}, :merge)
        end

        def default_protocol
          return if weld_protocols.empty?

          weld_protocols.keys.find { |k| service_traits.key?(k) }
        end
      end
    end
  end
end
