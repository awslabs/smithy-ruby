# frozen_string_literal: true

require 'stringio'

module Smithy
  module Anvil
    module Client
      module Views
        # @api private
        class EndpointProvider < View
          def initialize(plan)
            @plan = plan
            @model = plan.model
            service = Vise::ServiceIndex.new(@model).service.values.first
            @endpoint_rules = service['traits']['smithy.rules#endpointRuleSet']
            @parameters = @endpoint_rules['parameters']
                          .map { |id, data| EndpointParameter.new(id, data, @plan) }

            super()
          end

          attr_reader :parameters

          def namespace
            Tools::Namespace.namespace_from_gem_name(@plan.options[:gem_name])
          end

          def documentation
            '# TODO: Documentation'
          end

          def endpoint_rules_code
            res = StringIO.new
            res << "# endpoint rules\n"
            # map rules
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

            # if no rules match, raise an error
            res << indent("raise ArgumentError, 'No endpoint could be resolved'\n", 3)

            res.string
          end

          private

          def indent(s, levels = 3)
            ('  ' * levels) + s
          end

          def endpoint_rule(rule, levels = 3)
            res = StringIO.new
            if rule['conditions'] && !rule['conditions'].empty?
              res << conditions(rule['conditions'], levels)
              res << endpoint(rule['endpoint'], levels + 1)
              res << indent("end\n", levels)
            else
              res << endpoint(rule['endpoint'], levels)
            end
            res.string
          end

          def endpoint(endpoint, levels)
            res = StringIO.new
            res << "return Smithy::Client::EndpointRules::Endpoint.new(uri: #{str(endpoint['url'])}"
            res << ", headers: #{templated_hash_to_s(endpoint['headers'])}" if endpoint['headers']
            res << ", properties: #{templated_hash_to_s(endpoint['properties'])}" if endpoint['properties']
            if @has_account_id_endpoint_mode
              account_id_endpoint = endpoint['url'].include?('{AccountId}')
              res << ", metadata: { account_id_endpoint: #{account_id_endpoint} }"
            end
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
            res = StringIO.new
            if rule['conditions'] && !rule['conditions'].empty?
              res << conditions(rule['conditions'], levels)
              res << error(rule['error'], levels + 1)
              res << indent("end\n", levels)
            else
              res << error(rule['error'], levels)
            end
            res.string
          end

          def error(error, levels)
            indent("raise ArgumentError, #{str(error)}\n", levels)
          end

          def tree_rule(rule, levels = 3)
            res = StringIO.new
            if rule['conditions'] && !rule['conditions'].empty?
              res << conditions(rule['conditions'], levels)
              res << tree_rules(rule['rules'], levels + 1)
              res << indent("end\n", levels)
            else
              res << tree_rules(rule['rules'], levels)
            end
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
              "(#{condition['assign'].underscore} = #{fn(condition)})"
            else
              fn(condition)
            end
          end

          def str(s)
            if s.is_a?(Hash)
              if s['ref']
                s['ref'].underscore
              elsif s['fn']
                fn(s)
              else
                raise "Unknown string type: #{s}"
              end
            else
              template_str(s)
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
            res = indexes.shift.underscore
            res += indexes.map do |index|
              "['#{index}']"
            end.join
            res
          end

          def fn(fn)
            args = fn['argv'].map { |arg| fn_arg(arg) }.join(', ')
            "#{fn_name(fn['fn'])}(#{args})"
          end

          def fn_arg(arg)
            if arg.is_a?(Hash)
              if arg['ref']
                arg['ref'].underscore
              elsif arg['fn']
                fn(arg)
              else
                raise "Unexpected argument type: #{arg}"
              end
            elsif arg.is_a?(String)
              template_str(arg)
            else
              arg
            end
          end

          def fn_name(fn)
            unless (binding = @plan.function_bindings[fn])
              raise ArgumentError, "No endpoint function binding registered for #{fn}"
            end

            binding.ruby_method
          end
        end
      end
    end
  end
end
