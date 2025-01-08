# frozen_string_literal: true

module Smithy
  module Forge
    # Forges a gem for the types.
    class Types < Base
      # @param [Plan] plan The plan to forge.
      def initialize(plan)
        @plan = plan
        @gem_name = "#{plan.options[:gem_name]}-types"
        super
      end

      # @return [Enumerable<String, String>] The file paths and their contents to generate.
      def forge
        files = source_files
        files.each do |file, content|
          create_file file, content
        end
        files
      end

      private

      def source_files
        Enumerator.new do |e|
          e.yield "#{@gem_name}.gemspec", Views::Client::Gemspec.new(@plan).hammer
          e.yield '.rubocop.yml', Views::Client::RubocopYml.new(@plan).hammer
          e.yield "lib/#{@gem_name}.rb", Views::Client::Module.new(@plan).hammer
          e.yield "lib/#{@gem_name}/types.rb", Views::Client::Types.new(@plan).hammer
        end
      end
    end
  end
end
