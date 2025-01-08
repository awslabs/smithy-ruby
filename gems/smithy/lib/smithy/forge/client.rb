# frozen_string_literal: true

module Smithy
  module Forge
    # Forges a gem for the client.
    class Client < Base
      # @param [Plan] plan The plan to forge.
      def initialize(plan)
        @plan = plan
        @gem_name = plan.options[:gem_name]
        super
      end

      # @return [Enumerable<String, String>] The file paths and their contents to generate.
      def forge
        files = source_files
        files.each do |file, content|
          next if file == "lib/#{@gem_name}/customizations.rb" && should_skip_customizations?

          create_file file, content
        end
        files
      end

      private

      # rubocop:disable Metrics/AbcSize
      def source_files
        Enumerator.new do |e|
          e.yield "#{@gem_name}.gemspec", Views::Client::Gemspec.new(@plan).hammer
          e.yield '.rubocop.yml', Views::Client::Rubocop.new(@plan).hammer

          e.yield "lib/#{@gem_name}.rb", Views::Client::Module.new(@plan).hammer
          e.yield "lib/#{@gem_name}/client.rb", Views::Client::Client.new(@plan).hammer
          e.yield "lib/#{@gem_name}/customizations.rb", Views::Client::Customizations.new.hammer
          e.yield "lib/#{@gem_name}/shapes.rb", Views::Client::Shapes.new(@plan).hammer
          e.yield "lib/#{@gem_name}/types.rb", Views::Client::Types.new(@plan).hammer
          e.yield "lib/#{@gem_name}/errors.rb", Views::Client::Errors.new(@plan).hammer
          e.yield "lib/#{@gem_name}/endpoint_parameters.rb", Views::Client::EndpointParameters.new(@plan).hammer
          e.yield "lib/#{@gem_name}/endpoint_provider.rb", Views::Client::EndpointProvider.new(@plan).hammer
          e.yield "lib/#{@gem_name}/plugins/endpoint.rb", Views::Client::Plugins::Endpoint.new(@plan).hammer

          e.yield 'spec/spec_helper.rb', Views::Client::Specs::SpecHelper.new(@plan).hammer
          e.yield "spec/#{@gem_name}/endpoint_provider_spec.rb",
                  Views::Client::Specs::EndpointProviderSpec.new(@plan).hammer
        end
      end
      # rubocop:enable Metrics/AbcSize

      def should_skip_customizations?
        Dir["#{destination_root}/**/*"].any? { |f| f.include?('/customizations.rb') }
      end
    end
  end
end
