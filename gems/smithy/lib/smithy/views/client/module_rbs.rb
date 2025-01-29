# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class ModuleRbs < View
        def initialize(plan)
          @plan = plan
          @model = plan.model
          super()
        end

        def namespaces
          Util::Namespace.namespaces_from_gem_name(@plan.options[:gem_name])
        end
      end
    end
  end
end
