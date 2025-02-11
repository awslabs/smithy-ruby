# frozen_string_literal: true

require 'tmpdir'

module ClientHelper
  class << self
    # Generates a code artifact for the given type.
    # @param [Symbol] type The type of artifact to generate. For example,
    #  `:schema` or `:client`.
    # @param [Hash] options Additional options to pass to the generator.
    # (See Plan#initialize)
    # @option options [String] :fixture The name of the fixture to load in the
    #  fixtures folder relative to this file. Defaults to a path constructed
    #  from the module name.
    def generate(module_name, type, options = {})
      model = load_fixture(module_name, options)
      options[:destination_root] ||= Dir.mktmpdir
      plan = create_plan(module_name, model, type, options)
      Smithy.generate(plan)
      plan
    end

    # Generates source code for the given type.
    # @param [Symbol] type The type of artifact to generate. For example,
    #  `:schema` or `:client`.
    # @param [Hash] options Additional options to pass to the generator.
    # (See Plan#initialize)
    # @option options [String] :fixture The name of the fixture to load in the
    #  fixtures folder relative to this file. Defaults to a path constructed
    #  from the module name.
    def source(module_name, type, options = {})
      model = load_fixture(module_name, options)
      plan = create_plan(module_name, model, type, options)
      source = Smithy.source(plan)
      [plan.module_name, source]
    end

    def cleanup_gem(module_name, tmpdir = nil)
      undefine_module(module_name)
      return unless tmpdir

      if ENV.fetch('SMITHY_RUBY_KEEP_GENERATED_SOURCE', 'false') == 'true'
        puts "Leaving generated service in: #{tmpdir}"
      else
        FileUtils.rm_rf(tmpdir)
      end
      $LOAD_PATH.delete("#{tmpdir}/lib")
    end

    def undefine_module(module_name)
      module_names = module_name.split('::')
      module_names.reverse.each_cons(2) do |child, parent|
        Object.const_get(parent).send(:remove_const, child)
      end
      Object.send(:remove_const, module_names.first)
    end

    private

    def create_plan(module_name, model, type, options = {})
      plan_options = {
        module_name: module_name,
        gem_version: '0.1.0',
        quiet: ENV.fetch('SMITHY_RUBY_QUIET', 'true') == 'true'
      }.merge(options)
      Smithy::Plan.new(model, type, plan_options)
    end

    def load_fixture(module_name, options)
      fixture = options[:fixture] || module_name.split('::').map(&:underscore).join('/')
      model_dir = File.join(File.dirname(__FILE__), '..', 'fixtures', fixture)
      JSON.load_file(File.join(model_dir, 'model.json'))
    end
  end
end
