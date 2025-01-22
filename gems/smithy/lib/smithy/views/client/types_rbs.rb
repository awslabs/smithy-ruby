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

        def namespace
          Util::Namespace.namespace_from_gem_name(@plan.options[:gem_name])
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
          def initialize(model, id, structure)
            @id = id
            @structure = structure
            @model = model
          end

          def name
            Model::Shape.name(@id)
          end

          def members
            @structure['members'].map do |name, member|
              Member.new(@model, name, member)
            end
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
            Model::Rbs.type(@model, @id, @target)
          end
        end
      end
    end
  end
end
