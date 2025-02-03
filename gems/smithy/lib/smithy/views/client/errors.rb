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

        def module_name
          @plan.module_name
        end

        def errors
          Model::ServiceIndex
            .new(@model)
            .shapes_for(@plan.service)
            .select { |_key, shape| shape.fetch('traits', {}).any? { |id, _trait| id == 'smithy.api#error' } }
            .map { |id, structure| Error.new(id, structure) }
        end

        # @api private
        class Error
          def initialize(id, structure)
            @id = id
            @structure = structure
          end

          def docstrings
            @structure
              .fetch('traits', {})
              .fetch('smithy.api#documentation', "Error class for #{name}.")
              .split("\n")
          end

          def name
            Model::Shape.name(@id).camelize
          end

          def retryable?
            @structure
              .fetch('traits', {})
              .fetch('smithy.api#retryable', nil) != nil
          end

          def throttling?
            @structure
              .fetch('traits', {})
              .fetch('smithy.api#retryable', {})
              .fetch('throttling', false)
          end

          def members
            @structure['members'].map { |name, member| Member.new(name, member) }
          end

          # @api private
          class Member
            def initialize(name, shape)
              @name = name
              @shape = shape
            end

            attr_reader :shape

            def message?
              @name == 'message'
            end

            def docstrings
              @shape
                .fetch('traits', {})
                .fetch('smithy.api#documentation', '')
                .split("\n")
            end

            def name
              @name.underscore
            end
          end
        end
      end
    end
  end
end
