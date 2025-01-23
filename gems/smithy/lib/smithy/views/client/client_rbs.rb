# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class ClientRbs < View
        def initialize(plan)
          @plan = plan
          @model = plan.model
          @plugins = PluginList.new(plan)

          super()
        end

        def namespace
          Util::Namespace.namespace_from_gem_name(@plan.options[:gem_name])
        end

        def option_types
          # TODO: Ensure this order is correct when plugins override options
          @plugins
            .map(&:options)
            .flatten
            .uniq(&:name)
            .select(&:docstring) # include only documented options
            .sort_by(&:name)
            .to_h { |o| [o.name, rbs_type(o)] }
        end

        def operations
          @operations = Model::ServiceIndex
                        .new(@model)
                        .operations_for(@plan.service)
                        .map { |id, operation| Operation.new(@model, id, operation) }
        end

        private

        def rbs_type(option)
          return option.rbs_type if option.rbs_type

          return doc_to_rbs_types(option.doc_type) if option.doc_type

          'untyped'
        end

        # doc types may specify multiple types combined with ","
        def doc_to_rbs_types(doc_type)
          doc_type
            .to_s
            .split(',')
            .map(&:strip)
            .map { |t| doc_to_rbs_type(t) }
            .join(' | ')
        end

        def doc_to_rbs_type(doc_type)
          case doc_type
          when 'Boolean' then 'bool'
          else
            doc_type
          end
        end

        # @api private
        class Operation
          def initialize(model, id, operation)
            @model = model
            @id = id
            @operation = operation
          end
        end
      end
    end
  end
end
