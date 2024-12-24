# frozen_string_literal: true

module Smithy
  module Anvil
    module Client
      # @api private
      class EndpointParameter
        def initialize(id, data, plan, operation = nil)
          @id = id
          @data = data
          @plan = plan
          @model = @plan.model
          @service = Vise::ServiceIndex.new(@model).service.values.first

          @operation = operation

          @name = @id.underscore
          @value, @source = endpoint_parameter_value(operation)
        end

        attr_reader :id, :data, :name, :value, :source

        def documentation
          '# TODO!'
        end

        def default_value
          default = @data['default']
          case default
          when String then "\"#{default}\""
          when nil then 'nil'
          else
            default
          end
        end

        def validate_required?
          @data['required'] && !@data['default']
        end

        def create_from_config?
          @source == 'config'
        end

        def built_in?
          @data['builtIn']
        end

        def built_in_binding
          @plan.built_in_bindings[@data['builtIn']]
        end

        def client_context?
          @service['traits']['smithy.rules#clientContextParams']&.key?(@id) && !@data['builtIn']
        end

        def client_context_doc
          @service['traits']['smithy.rules#clientContextParams'][@id]['documentation']
        end

        private

        # Highest to lowest priority:
        # 1. staticContextParams
        # 2. contextParam
        # 3. operationContextParams
        # 4. clientContextParams (always sourced from config)
        # 5. Built-In Bindings (sourced from config in most cases)
        # @return [value, source].  source may be one of [operation, config, default]
        def endpoint_parameter_value(operation)
          unless operation.nil?
            source = 'operation'
            value = static_context_param(operation)
            value ||= context_param_value(operation)
            value ||= operation_context_param_value(operation)
          end

          unless value
            value = client_context_param_value
            source = 'config'
          end

          unless value
            value = built_in_param_value
            source = 'config'
          end

          [value, source]
        end

        def static_context_param(operation)
          value = operation.fetch('traits', {}).fetch('smithy.rules#staticContextParams', {})
                           .fetch(@id, {}).fetch('value', nil)
          if !value.nil? && value.is_a?(String)
            "\"#{value}\""
          else
            value
          end
        end

        def context_param_value(operation)
          return nil unless operation['input']

          input_shape = @model['shapes'][operation['input']['target']]
          members = input_shape.fetch('members', {})
          context_param_member(members)
        end

        def context_param_member(members)
          members.detect do |(member_name, member_def)|
            # TODO: We need a method to get member traits.
            context_param = member_def.fetch('traits', {}).fetch('smithy.rules#contextParam', {})
            break "context.params[:#{member_name.underscore}]" if context_param.fetch('name', nil) == @id
          end
        end

        def operation_context_param_value(operation)
          return nil unless operation['input']

          binding = operation.fetch('traits', {}).fetch('smithy.rules#operationContextParams', {})[@id]

          return nil unless binding

          "JMESPath.search(\"#{Tools::Underscore.underscore_jmespath(binding['path'])}\", context.params)"
        end

        def client_context_param_value
          return unless client_context?

          "config.#{name}"
        end

        def built_in_param_value
          return unless @data['builtIn']

          built_in_binding.render_build(@plan, nil)
        end
      end
    end
  end
end
