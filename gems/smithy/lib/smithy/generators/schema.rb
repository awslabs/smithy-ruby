# frozen_string_literal: true

module Smithy
  module Generators
    # Generates a gem for the types.
    class Schema < Base
      # @param [Plan] plan The plan to generate.
      def initialize(plan)
        @plan = plan
        @gem_name = "#{plan.options[:gem_name]}-schema"
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
        end
      end

      def source_files
        Enumerator.new do |e|
          e.yield "lib/#{@gem_name}.rb", Views::Client::Module.new(@plan).render
          e.yield "lib/#{@gem_name}/types.rb", Views::Client::Types.new(@plan).render
          e.yield "lib/#{@gem_name}/shapes.rb", Views::Client::Shapes.new(@plan).render
        end
      end

      def should_skip_customizations?
        Dir["#{destination_root}/**/*"].any? { |f| f.include?('/customizations.rb') }
      end
    end
  end
end
