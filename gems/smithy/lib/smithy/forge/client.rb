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
          e.yield "lib/#{@gem_name}.rb", render_module
          e.yield "lib/#{@gem_name}/client.rb", render_client
          e.yield "lib/#{@gem_name}/customizations.rb", render_customizations
          e.yield "lib/#{@gem_name}/shapes.rb", render_shapes
          e.yield "lib/#{@gem_name}/types.rb", render_types
          e.yield "lib/#{@gem_name}/errors.rb", render_errors
        end
      end

      def render_gemspec
        Anvil::Client::Views::Gemspec.new(@plan).hammer
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

      def should_skip_customizations?
        Dir["#{destination_root}/**/*"].any? { |f| f.include?('/customizations.rb') }
      end
    end
  end
end
