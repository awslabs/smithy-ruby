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

      # @return [Enumerator<String, String>] The file paths and their contents to generate.
      def generate
        files = source_files
        files.each do |file, content|
          next if file == "lib/#{@gem_name}/customizations.rb" && should_skip_customizations?

          create_file file, content
        end
        files
      end

      private

      # rubocop:disable Metrics
      def source_files
        Enumerator.new do |e|
          e.yield "#{@gem_name}.gemspec", Views::Client::Gemspec.new(@plan).render
          e.yield '.rubocop.yml', Views::Client::RubocopYml.new(@plan).render

          e.yield "lib/#{@gem_name}.rb", Views::Client::Module.new(@plan).render
          e.yield "lib/#{@gem_name}/customizations.rb", Views::Client::Customizations.new.render
          e.yield "lib/#{@gem_name}/errors.rb", Views::Client::Errors.new(@plan).render
          e.yield "lib/#{@gem_name}/endpoint_parameters.rb", Views::Client::EndpointParameters.new(@plan).render
          e.yield "lib/#{@gem_name}/endpoint_provider.rb", Views::Client::EndpointProvider.new(@plan).render
          e.yield "lib/#{@gem_name}/plugins/endpoint.rb", Views::Client::EndpointPlugin.new(@plan).render
          e.yield "lib/#{@gem_name}/shapes.rb", Views::Client::Shapes.new(@plan).render
          e.yield "lib/#{@gem_name}/types.rb", Views::Client::Types.new(@plan).render

          e.yield "lib/#{@gem_name}/client.rb", Views::Client::Client.new(@plan).render

          e.yield 'spec/spec_helper.rb', Views::Client::SpecHelper.new(@plan).render
          e.yield "spec/#{@gem_name}/endpoint_provider_spec.rb", Views::Client::EndpointProviderSpec.new(@plan).render

          e.yield "sig/#{@gem_name}.rbs", Views::Client::ModuleRbs.new(@plan).render
          e.yield 'sig/errors.rbs', Views::Client::ErrorsRbs.new(@plan).render
          e.yield 'sig/endpoint_parameters.rbs', Views::Client::EndpointParametersRbs.new(@plan).render
          e.yield 'sig/endpoint_provider.rbs', Views::Client::EndpointProviderRbs.new(@plan).render
          e.yield 'sig/shapes.rbs', Views::Client::ShapesRbs.new(@plan).render
          e.yield 'sig/types.rbs', Views::Client::TypesRbs.new(@plan).render
        end
      end
      # rubocop:enable Metrics

      def should_skip_customizations?
        Dir["#{destination_root}/**/*"].any? { |f| f.include?('/customizations.rb') }
      end
    end
  end
end
