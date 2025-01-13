# frozen_string_literal: true

module Smithy
  module Views
    module Client
      # @api private
      class EndpointParameter
        def initialize(id, data, plan, operation = nil)
          @id = id
          @data = data
          @plan = plan
          @model = @plan.model
          @service = @plan.service.values.first

          @operation = operation

          @name = @id.underscore
          @value, @source = endpoint_parameter_value(operation)
        end

        attr_reader :id, :data, :name, :source, :value

        def docstrings
          @data['documentation'].split("\n")
        end

        def documentation_type
          case @data['type']
          when 'stringArray' then 'Array<String>'
          when 'string' then 'String'
          when 'boolean' then 'Boolean'
          else
            @data['type']
          end
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
          @built_in_binding ||=
            @plan.welds
                 .map(&:endpoint_built_in_bindings)
                 .map { |b| b[@data['builtIn']] }
                 .find { |b| !b.nil? }
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
            value = static_context_param(operation)
            value = context_param_value(operation) if value.nil?
            value = operation_context_param_value(operation) if value.nil?
            source = 'operation' unless value.nil?
          end

          value, source = client_context_param_value if value.nil?
          value, source = built_in_param_value if value.nil?

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

          input = Model.shape(@model, operation['input']['target'])
          context_param_member(input['members'])
        end

        def context_param_member(members)
          members.find do |(member_name, member_def)|
            context_param = member_def.fetch('traits', {}).fetch('smithy.rules#contextParam', {})
            break "params[:#{member_name.underscore}]" if context_param.fetch('name', nil) == @id
          end
        end

        def operation_context_param_value(operation)
          return nil unless operation['input']

          binding = operation.fetch('traits', {}).fetch('smithy.rules#operationContextParams', {})[@id]

          return nil unless binding

          "JMESPath.search(\"#{Util::Underscore.underscore_jmespath(binding['path'])}\", params)"
        end

        def client_context_param_value
          return unless client_context?

          ["config.#{name}", 'config']
        end

        def built_in_param_value
          return unless @data['builtIn']

          [built_in_binding[:render_build].call(@plan, nil), 'config']
        end
      end
    end
  end
end
