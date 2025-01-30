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
          @plan.gem_namespace
        end

        def types
          Model::ServiceIndex
            .new(@model)
            .shapes_for(@plan.service)
            .select { |_key, shape| %w[structure union].include?(shape['type']) }
            .map { |id, shape| Type.new(@model, id, shape) }
        end

        # @api private
        class Type
          def initialize(model, id, shape)
            @model = model
            @id = id
            @shape = shape
          end

          def documentation
            '# TODO!'
          end

          def name
            Model::Shape.name(@id).camelize
          end

          def member_names
            @shape['members'].keys.map(&:underscore)
          end

          def members
            @shape['members']
              .map { |name, member| Member.new(@model, name, member['target']) }
          end

          def type
            @shape['type']
          end
        end

        # @api private
        class Member
          def initialize(model, name, id)
            @name = name
            @id = id
            @shape = Model.shape(model, id)
          end

          attr_reader :name, :id, :shape
        end
      end
    end
  end
end
