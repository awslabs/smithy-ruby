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
      class_option :quiet, type: :boolean, default: false, desc: 'Suppress all output.'

      def self.gem_options!
        method_option :name, type: :string,
                             desc: 'The name of the service to generate code for.' \
                                   'Defaults to the name of the first service shape found in the model.'
        method_option :module_name, type: :string,
                                    desc: 'The module name to generate, e.g. `Organization::Weather`. ' \
                                          'Defaults to the name of the service.'
        method_option :gem_name, type: :string, required: true,
                                 desc: 'The name of the gem to generate. Defaults to a gem name derived ' \
                                       'from the module name, suffixed with "-schema" if type is schema.'
        method_option :gem_version, type: :string, required: true, desc: 'The version of the gem to generate.'
      end

      gem_options!
      desc 'schema', 'Generates a schema for the model provided to STDIN.'
      def schema
        invoke(:schema, options)
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
          Smithy.generate(plan)
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
