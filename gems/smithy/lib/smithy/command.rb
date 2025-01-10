# frozen_string_literal: true

require 'json'

module Smithy
  # @api private
  module Command
    # @api private
    class Base < Thor
      # Necessary to report the correct status to the parent process (`smithy build`)
      def self.exit_on_failure?
        true
      end
    end

    # @api private
    class Smith < Base
      class_option :destination_root, type: :string, required: true,
                                      default: ENV.fetch('SMITHY_PLUGIN_DIR', nil),
                                      desc: 'The destination directory for the generated code.'

      def self.gem_options!
        method_option :gem_name, type: :string, required: true,
                                 desc: 'The name of the gem to generate.'
        method_option :gem_version, type: :string, required: true,
                                    desc: 'The version of the gem to generate.'
        method_option :gem_namespace, type: :string,
                                      desc: 'The namespace of the gem to generate, e.g. `MyGem::Namespace`.' \
                                            'If not provided, the gem name will be used to infer the namespace.'
      end

      gem_options!
      desc 'types', 'Generates types for the model provided to STDIN.'
      def types
        invoke(:types, options)
      end

      gem_options!
      desc 'client', 'Generates a client for the model provided to STDIN.'
      def client
        invoke(:client, options)
      end

      desc 'server', 'Generates a server for the model provided to STDIN.'
      def server
        raise NotImplementedError, 'server generation is not yet implemented'
      end

      no_tasks do
        def invoke(type, options)
          model = JSON.parse($stdin.read)
          plan = Smithy::Plan.new(model, type, options)
          Smithy.smith(plan)
        end
      end
    end

    # @api private
    class CLI < Base
      desc 'smith', 'Generate code using a Smithy model.'
      subcommand 'smith', Smith
    end
  end
end
