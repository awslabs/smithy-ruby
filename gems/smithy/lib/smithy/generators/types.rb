# frozen_string_literal: true

module Smithy
  module Generators
    # Generates a gem for the types.
    class Types < Base
      # @param [Plan] plan The plan to generate.
      def initialize(plan)
        @plan = plan
        @gem_name = "#{plan.options[:gem_name]}-types"
        super
      end

      # @return [Enumerator<String, String>] The file paths and their contents to generate.
      def generate
        files = source_files
        files.each do |file, content|
          create_file file, content
        end
        files
      end

      private

      def source_files
        Enumerator.new do |e|
          e.yield "#{@gem_name}.gemspec", Views::Client::Gemspec.new(@plan).render
          e.yield '.rubocop.yml', Views::Client::RubocopYml.new(@plan).render
          e.yield "lib/#{@gem_name}.rb", Views::Client::Module.new(@plan).render
          e.yield "lib/#{@gem_name}/types.rb", Views::Client::Types.new(@plan).render

          e.yield "sig/#{@gem_name}.rbs", Views::Client::ModuleRbs.new(@plan).render
          e.yield 'sig/types.rbs', Views::Client::TypesRbs.new(@plan).render
        end
      end
    end
  end
end
