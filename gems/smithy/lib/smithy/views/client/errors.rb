# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class Errors < View
        def initialize(plan)
          @plan = plan
          @model = plan.model
          super()
        end

        def namespace
          Util::Namespace.namespace_from_gem_name(@plan.options[:gem_name])
        end

        def errors
          Model::ServiceIndex
            .new(@model)
            .shapes_for(@plan.service)
            .select { |_key, shape| shape['traits']&.any? { |id, _trait| id == 'smithy.api#error' } }
            .map { |id, structure| Error.new(id, structure) }
        end

        # @api private
        class Error
          def initialize(id, structure)
            @id = id
            @structure = structure
          end

          def documentation
            '# TODO!'
          end

          def name
            Model::Shape.name(@id)
          end

          def member_names
            @structure['members'].keys.map(&:underscore)
          end
        end
      end
    end
  end
end
