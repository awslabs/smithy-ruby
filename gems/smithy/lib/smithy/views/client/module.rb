# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class Module < View
        def initialize(plan)
          @plan = plan
          @model = plan.model
          super()
        end

        def gem_name
          @plan.gem_name
        end

        def gem_version
          @plan.gem_version
        end

        def requires
          if @plan.type == :schema
            ['smithy-model']
          else
            ['smithy-client']
          end
        end

        def documentation
          _id, service = @model.shapes.find { |_key, shape| shape.is_a?(Model::ServiceShape) }
          _id, trait = service.traits.find { |_id, trait| trait.id == 'smithy.api#documentation' }
          "# #{trait.data}"
        end

        def module_names
          @plan.module_name.split('::')
        end

        def relative_requires
          return [] unless @plan.destination_root
          return %i[customizations types shapes] if @plan.type == :schema

          # types must come before shapes
          %w[types shapes client customizations errors endpoint_parameters endpoint_provider]
        end
      end
    end
  end
end
