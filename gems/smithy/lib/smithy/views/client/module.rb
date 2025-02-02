# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class Module < View
        def initialize(plan)
          @plan = plan
          @model = plan.model
          @gem_name = plan.gem_name
          @gem_version = plan.gem_version
          super()
        end

        attr_reader :gem_name, :gem_version

        def documentation
          _id, service = @model.shapes.find { |_key, shape| shape.is_a?(Model::ServiceShape) }
          _id, trait = service.traits.find { |_id, trait| trait.id == 'smithy.api#documentation' }
          "# #{trait.data}"
        end

        def namespaces
          @plan.module_name.split('::')
        end

        def requires
          return [] unless @plan.destination_root
          return %i[customizations types shapes] if @plan.type == :schema

          # Order matters here - plugins must come before client, types must come before shapes
          %w[plugins/endpoint types shapes client customizations errors endpoint_parameters endpoint_provider]
        end
      end
    end
  end
end
