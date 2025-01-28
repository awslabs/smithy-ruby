# frozen_string_literal: true

module Smithy
  module Generators
    # Generates a gem for the client.
    class Client < Base
      # @param [Plan] plan The plan to generate.
      def initialize(plan)
        @plan = plan
        @gem_name = plan.options[:gem_name]
        super
      end

      def generate
        gem_files.each_with_object([]) do |(file, content), files|
          next if file == "lib/#{@gem_name}/customizations.rb" && should_skip_customizations?

          create_file file, content
          files << file
        end
      end

      def source
        source = source_files.map { |_file, content| content }.join("\n")
        Object.module_eval(source)
        Object.const_get(@plan.gem_namespace)
      rescue Exception => e # rubocop:disable Lint/RescueException
        puts "Error evaluating source:\n#{source}"
        raise e
      end

      private

      def gem_files
        Enumerator.new do |e|
          e.yield "#{@gem_name}.gemspec", Views::Client::Gemspec.new(@plan).render
          e.yield '.rubocop.yml', Views::Client::RubocopYml.new(@plan).render

          source_files.each { |file, content| e.yield file, content }
          e.yield "lib/#{@gem_name}/customizations.rb", Views::Client::Customizations.new.render

          spec_files.each { |file, content| e.yield file, content }
        end
      end

      # rubocop:disable Metrics/AbcSize
      def source_files
        Enumerator.new do |e|
          e.yield "lib/#{@gem_name}.rb", Views::Client::Module.new(@plan).render
          e.yield "lib/#{@gem_name}/errors.rb", Views::Client::Errors.new(@plan).render
          e.yield "lib/#{@gem_name}/endpoint_parameters.rb", Views::Client::EndpointParameters.new(@plan).render
          e.yield "lib/#{@gem_name}/endpoint_provider.rb", Views::Client::EndpointProvider.new(@plan).render
          code_generated_plugins.each { |plugin| e.yield plugin.require_path, plugin.source }
          e.yield "lib/#{@gem_name}/types.rb", Views::Client::Types.new(@plan).render
          e.yield "lib/#{@gem_name}/shapes.rb", Views::Client::Shapes.new(@plan).render
          e.yield "lib/#{@gem_name}/client.rb", Views::Client::Client.new(@plan, code_generated_plugins).render
        end
      end
      # rubocop:enable Metrics/AbcSize

      def spec_files
        Enumerator.new do |e|
          e.yield 'spec/spec_helper.rb', Views::Client::SpecHelper.new(@plan).render
          e.yield "spec/#{@gem_name}/endpoint_provider_spec.rb", Views::Client::EndpointProviderSpec.new(@plan).render
        end
      end

      def code_generated_plugins
        Enumerator.new do |e|
          e.yield Views::Client::Plugin.new(
            class_name: "#{@plan.gem_namespace}::Plugins::Endpoint",
            require_path: "lib/#{@gem_name}/plugins/endpoint.rb",
            source: Views::Client::EndpointPlugin.new(@plan).render
          )
        end
      end

      def should_skip_customizations?
        Dir["#{destination_root}/**/*"].any? { |f| f.include?('/customizations.rb') }
      end
    end
  end
end
