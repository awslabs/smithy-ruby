# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class Types < View
        def initialize(plan)
          @plan = plan
          @model = plan.model
          super()
        end

        def namespace
          @plan.module_name
        end

        def types
          Model::ServiceIndex
            .new(@model)
            .shapes_for(@plan.service)
            .select { |_key, shape| %w[structure union].include?(shape['type']) }
            .map { |id, structure| Type.new(id, structure) }
        end

        # @api private
        class Type
          def initialize(id, structure)
            @id = id
            @structure = structure
          end

          def documentation
            '# TODO!'
          end

          def name
            Model::Shape.name(@id).camelize
          end

          def member_names
            @structure['members'].keys.map(&:underscore)
          end
        end
      end
    end
  end
end
