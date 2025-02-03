# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class TypesRbs < View
        def initialize(plan)
          @plan = plan
          @model = plan.model
          super()
        end

        def module_name
          @plan.module_name
        end

        def types
          @types ||= Model::ServiceIndex
                     .new(@model)
                     .shapes_for(@plan.service)
                     .select { |_key, shape| %w[structure union].include?(shape['type']) }
                     .map { |id, structure| Type.new(@model, id, structure) }
        end

        # @api private
        class Type
          def initialize(model, id, shape)
            @id = id
            @shape = shape
            @model = model
          end

          def name
            Model::Shape.name(@id).camelize
          end

          def members
            @shape['members'].map do |name, member|
              Member.new(@model, name, member)
            end
          end

          def type
            @shape['type']
          end
        end

        # @api private
        class Member
          def initialize(model, name, member)
            @name = name.underscore
            @id = member['target']
            @model = model
            @target = Model.shape(@model, member['target'])
          end

          attr_reader :name

          def rbs_type
            Model::RBS.type(@model, @id, @target)
          end
        end
      end
    end
  end
end
