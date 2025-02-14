# frozen_string_literal: true

require 'stringio'

module Smithy
  module Views
    module Client
      # @api private
      class EndpointProvider < View
        def initialize(plan)
          @plan = plan
          @model = plan.model
          service = @plan.service.values.first
          @endpoint_rules = service['traits']['smithy.rules#endpointRuleSet']
          @parameters = @endpoint_rules['parameters']
                        .map { |id, data| EndpointParameter.new(id, data, @plan) }
          @endpoint_function_bindings =
            plan.welds.map(&:endpoint_function_bindings).reduce({}, :merge)
          @assigned_variables = []
          super()
        end

        attr_reader :parameters

        def module_name
          @plan.module_name
        end

        def endpoint_rules_code
          res = StringIO.new
          @endpoint_rules['rules'].each do |rule|
            case rule['type']
            when 'endpoint'
              res << endpoint_rule(rule, 3)
            when 'error'
              res << error_rule(rule, 3)
            when 'tree'
              res << tree_rule(rule, 3)
            else
              raise "Unknown rule type: #{rule['type']}"
            end
          end

          res.string
        end

        private

        def indent(str, levels = 3)
          ('  ' * levels) + str
        end

        def endpoint_rule(rule, levels = 3)
          if rule['conditions'] && !rule['conditions'].empty?
            endpoint_rule_with_condition(levels, rule)
          else
            endpoint(rule['endpoint'], levels)
          end
        end

        def endpoint_rule_with_condition(levels, rule)
          res = StringIO.new
          res << conditions(rule['conditions'], levels)
          res << endpoint(rule['endpoint'], levels + 1)
          res << indent("end\n", levels)
          res.string
        end

        def endpoint(endpoint, levels)
          res = StringIO.new
          res << "return Smithy::Client::EndpointRules::Endpoint.new(uri: #{str(endpoint['url'])}"
          res << ", headers: #{templated_hash_to_s(endpoint['headers'])}" if endpoint['headers']
          res << ", properties: #{templated_hash_to_s(endpoint['properties'])}" if endpoint['properties']
          res << ")\n"
          indent(res.string, levels)
        end

        def templated_hash_to_s(hash)
          template_hash_values(hash).to_s.gsub('\#{', '#{') # unescape references
        end

        def template_hash_values(hash)
          hash.transform_values do |v|
            template_hash_value(v)
          end
        end

        def template_hash_value(value)
          case value
          when Hash
            template_hash_values(value)
          when Array
            value.map { |v| template_hash_value(v) }
          when String
            template_str(value, wrap: false)
          else
            value
          end
        end

        def error_rule(rule, levels = 3)
          if rule['conditions'] && !rule['conditions'].empty?
            error_rule_with_condition(levels, rule)
          else
            error(rule['error'], levels)
          end
        end

        def error_rule_with_condition(levels, rule)
          res = StringIO.new
          res << conditions(rule['conditions'], levels)
          res << error(rule['error'], levels + 1)
          res << indent("end\n", levels)
          res.string
        end

        def error(error, levels)
          indent("raise ArgumentError, #{str(error)}", levels)
        end

        def tree_rule(rule, levels = 3)
          if rule['conditions'] && !rule['conditions'].empty?
            tree_rule_with_condition(levels, rule)
          else
            tree_rules(rule['rules'], levels)
          end
        end

        def tree_rule_with_condition(levels, rule)
          res = StringIO.new
          res << conditions(rule['conditions'], levels)
          res << tree_rules(rule['rules'], levels + 1)
          res << indent("end\n", levels)
          res.string
        end

        def tree_rules(rules, levels)
          res = StringIO.new
          rules.each do |rule|
            case rule['type']
            when 'endpoint'
              res << endpoint_rule(rule, levels)
            when 'error'
              res << error_rule(rule, levels)
            when 'tree'
              res << tree_rule(rule, levels)
            else
              raise "Unknown rule type: #{rule['type']}"
            end
          end
          res.string
        end

        def conditions(conditions, level)
          res = StringIO.new
          cnd_str = conditions.map { |c| condition(c) }.join(' && ')
          res << indent("if #{cnd_str}\n", level)
          res.string
        end

        def condition(condition)
          if condition['assign']
            @assigned_variables << condition['assign']
            "(#{condition['assign'].underscore} = #{function(condition)})"
          else
            function(condition)
          end
        end

        def str(str)
          if str.is_a?(Hash)
            if str['ref']
              variable(str['ref'])
            elsif str['fn']
              function(str)
            else
              raise "Unknown string type: #{str}"
            end
          else
            template_str(str)
          end
        end

        def template_str(string, wrap: true)
          string.scan(/\{.+?\}/).each do |capture|
            value = capture[1..-2] # strips curly brackets
            string = string.gsub(capture, "\#{#{template_replace(value)}}")
          end
          string = string.gsub('"', '\"')
          wrap ? "\"#{string}\"" : string
        end

        def template_replace(value)
          indexes = value.split('#')
          res = variable(indexes.shift)
          res + indexes.map do |index|
            "['#{index}']"
          end.join
        end

        def function(function)
          args = function['argv'].map { |arg| fn_arg(arg) }.join(', ')
          "#{fn_name(function['fn'])}(#{args})"
        end

        def fn_arg(arg)
          if arg.is_a?(Hash)
            if arg['ref']
              variable(arg['ref'])
            elsif arg['fn']
              function(arg)
            else
              raise "Unexpected argument type: #{arg}"
            end
          elsif arg.is_a?(String)
            template_str(arg)
          else
            arg
          end
        end

        def variable(variable)
          if @assigned_variables.include?(variable)
            variable.underscore
          else
            "parameters.#{variable.underscore}"
          end
        end

        def fn_name(function)
          unless (binding = @endpoint_function_bindings[function])
            raise ArgumentError, "No endpoint function binding registered for #{function}"
          end

          binding
        end
      end
    end
  end
end
