# frozen_string_literal: true

module Smithy
  module Anvil
    module Client
      module Views
        # @api private
        class ClientClass < View
          def initialize(plan)
            @plan = plan
            @model = plan.model
            super()
          end

          def plugins
            plugins = []
            # TODO: Determine how to add this based upon what protocol is used
            plugins << 'Smithy::Client::Plugins::NetHTTP'
            plugins << 'Plugins::Endpoint'
            plugins
          end

          def namespace
            Tools::Namespace.namespace_from_gem_name(@plan.options[:gem_name])
          end

          def gem_name
            @plan.options[:gem_name]
          end

          def gem_version
            @plan.options[:gem_version]
          end

          def operations
            Vise::ServiceIndex
              .new(@model)
              .operations_for(@plan.service)
              .map { |id, operation| Operation.new(@model, id, operation) }
          end

          # @api private
          class Operation
            def initialize(model, id, operation)
              @model = model
              @id = id
              @operation = operation
            end

            def docstrings
              RequestSyntaxExample.new(@model, @id, @operation).docstrings.each do |l|
                puts l
              end
              RequestSyntaxExample.new(@model, @id, @operation).docstrings
            end

            def name
              Vise::Shape.name(@id).underscore
            end
          end
        end
      end
    end
  end
end
