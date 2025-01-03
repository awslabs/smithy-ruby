# frozen_string_literal: true

module Smithy
  module Anvil
    module Client
      module Views
        module Sig
          # @api private
          # This is entirely duplicated.  We can customize it to rbs, but a lot of it probably just needs to be the same
          class Client < View
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
                .map { |id, shape| Operation.new(id, shape) }
            end

            # @api private
            class Operation
              def initialize(id, operation)
                @id = id
                @operation = operation
              end

              def documentation
                '# TODO!'
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
end
