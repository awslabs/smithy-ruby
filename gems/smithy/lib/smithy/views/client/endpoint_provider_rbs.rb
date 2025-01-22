# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class EndpointProviderRbs < View
        def initialize(plan)
          @plan = plan
          super()
        end

        def namespace
          Util::Namespace.namespace_from_gem_name(@plan.options[:gem_name])
        end
      end
    end
  end
end
