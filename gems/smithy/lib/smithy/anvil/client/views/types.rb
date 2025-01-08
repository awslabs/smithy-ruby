# frozen_string_literal: true

module Smithy
  module Anvil
    module Client
      module Views
        # @api private
        class Types < View
          def initialize(plan)
            @plan = plan
            @model = plan.model
            super()
          end

          def namespace
            Util::Namespace.namespace_from_gem_name(@plan.options[:gem_name])
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
end
