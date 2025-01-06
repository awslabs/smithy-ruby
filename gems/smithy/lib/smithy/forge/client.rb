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

      def source_files
        Enumerator.new do |e|
          e.yield "#{@gem_name}.gemspec", render_gemspec
          e.yield '.rubocop.yml', render_rubocop

          e.yield "lib/#{@gem_name}.rb", render_module
          e.yield "lib/#{@gem_name}/client.rb", render_client
          e.yield "lib/#{@gem_name}/customizations.rb", render_customizations
          e.yield "lib/#{@gem_name}/shapes.rb", render_shapes
          e.yield "lib/#{@gem_name}/types.rb", render_types
          e.yield "lib/#{@gem_name}/errors.rb", render_errors
          e.yield "lib/#{@gem_name}/endpoint_parameters.rb", render_endpoint_parameters
          e.yield "lib/#{@gem_name}/endpoint_provider.rb", render_endpoint_provider
          e.yield "lib/#{@gem_name}/plugins/endpoint.rb", render_endpoint_plugin

          e.yield 'spec/spec_helper.rb', render_spec_helper
          e.yield "spec/#{@gem_name}/endpoint_provider_spec.rb", render_endpoint_provider_spec
        end
      end
      # rubocop:enable Metrics/AbcSize

      def render_gemspec
        Anvil::Client::Views::Gemspec.new(@plan).hammer
      end

      def render_rubocop
        Anvil::Client::Views::Rubocop.new(@plan).hammer
      end

      def render_module
        Anvil::Client::Views::Module.new(@plan).hammer
      end

      def render_client
        Anvil::Client::Views::ClientClass.new(@plan).hammer
      end

      def render_customizations
        Anvil::Client::Views::Customizations.new.hammer
      end

      def render_shapes
        Anvil::Client::Views::Shapes.new(@plan).hammer
      end

      def render_types
        Anvil::Client::Views::Types.new(@plan).hammer
      end

      def render_errors
        Anvil::Client::Views::Errors.new(@plan).hammer
      end

      def render_endpoint_parameters
        Anvil::Client::Views::EndpointParameters.new(@plan).hammer
      end

      def render_endpoint_provider
        Anvil::Client::Views::EndpointProvider.new(@plan).hammer
      end

      def render_endpoint_plugin
        Anvil::Client::Views::Plugins::Endpoint.new(@plan).hammer
      end

      def render_spec_helper
        Anvil::Client::Views::Specs::SpecHelper.new(@plan).hammer
      end

      def render_endpoint_provider_spec
        Anvil::Client::Views::Specs::EndpointProviderSpec.new(@plan).hammer
      end

      def should_skip_customizations?
        Dir["#{destination_root}/**/*"].any? { |f| f.include?('/customizations.rb') }
      end
    end
  end
end
