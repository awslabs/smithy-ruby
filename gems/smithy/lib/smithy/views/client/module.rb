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
          if @plan.type == :types
            "#{@plan.options[:gem_name]}-types"
          else
            @plan.options[:gem_name]
          end
        end

        def gem_version
          @plan.options[:gem_version]
        end

        def documentation
          _id, service = @model.shapes.find { |_key, shape| shape.is_a?(Model::ServiceShape) }
          _id, trait = service.traits.find { |_id, trait| trait.id == 'smithy.api#documentation' }
          "# #{trait.data}"
        end

        def namespaces
          Util::Namespace.namespaces_from_gem_name(@plan.options[:gem_name])
        end

        def requires
          if @plan.type == :types
            [:types]
          else
            # Order matters here - plugins must come before client, types and shapes must come before client
            %w[plugins/endpoint types shapes client customizations errors endpoint_parameters endpoint_provider]
          end
        end
      end
    end
  end
end
