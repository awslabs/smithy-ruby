# frozen_string_literal: true

require 'tmpdir'

module ClientHelper
  class << self
    def sample_shapes
      {
        'smithy.ruby.tests#SampleClient' => {
          'type' => 'service',
          'operations' => [
            { 'target' => 'smithy.ruby.tests#Operation' }
          ]
        },
        'smithy.ruby.tests#Operation' => {
          'type' => 'operation',
          'input' => { 'target' => 'smithy.ruby.tests#Structure' },
          'output' => { 'target' => 'smithy.ruby.tests#Structure' }
        },
        'smithy.ruby.tests#Enum' => {
          'type' => 'enum',
          'members' => {
            'member' => {
              'target' => 'smithy.api#Unit',
              'traits' => { 'smithy.api#enumValue' => 'value' }
            }
          }
        },
        'smithy.ruby.tests#intEnum' => {
          'type' => 'intEnum',
          'members' => {
            'member' => {
              'target' => 'smithy.api#Unit',
              'traits' => { 'smithy.api#enumValue' => 1 }
            }
          }
        },
        'smithy.ruby.tests#List' => {
          'type' => 'list',
          'member' => { 'target' => 'smithy.api#String' }
        },
        'smithy.ruby.tests#Map' => {
          'type' => 'map',
          'key' => { 'target' => 'smithy.api#String' },
          'value' => { 'target' => 'smithy.api#String' }
        },
        'smithy.ruby.tests#Structure' => {
          'type' => 'structure',
          'members' => {
            'bigDecimal' => { 'target' => 'smithy.api#BigDecimal' },
            'bigInteger' => { 'target' => 'smithy.api#BigInteger' },
            'blob' => { 'target' => 'smithy.api#Blob' },
            'boolean' => { 'target' => 'smithy.api#Boolean' },
            'byte' => { 'target' => 'smithy.api#Byte' },
            'document' => { 'target' => 'smithy.api#Document' },
            'double' => { 'target' => 'smithy.api#Double' },
            'enum' => { 'target' => 'smithy.ruby.tests#Enum' },
            'float' => { 'target' => 'smithy.api#Float' },
            'intEnum' => { 'target' => 'smithy.ruby.tests#intEnum' },
            'integer' => { 'target' => 'smithy.api#Integer' },
            'list' => { 'target' => 'smithy.ruby.tests#List' },
            'long' => { 'target' => 'smithy.api#Long' },
            'map' => { 'target' => 'smithy.ruby.tests#Map' },
            'short' => { 'target' => 'smithy.api#Short' },
            'string' => { 'target' => 'smithy.api#String' },
            'structure' => { 'target' => 'smithy.ruby.tests#Structure' },
            'timestamp' => { 'target' => 'smithy.api#Timestamp' },
            'union' => { 'target' => 'smithy.ruby.tests#Union' }
          }
        },
        'smithy.ruby.tests#Union' => {
          'type' => 'union',
          'members' => {
            'string' => { 'target' => 'smithy.api#String' }
          }
        }
      }
    end

    # @param [Array<String>] module_names A list of module names for the
    #  generated code. For example, `['Company', 'Weather']` would generate
    #  code in the `Company::Weather` namespace.
    # @param [Symbol] type The type of artifact to generate. For example,
    #  `:schema` or `:client`.
    # @param [Hash] options Additional options to pass to the generator.
    # (See Plan#initialize)
    # @option options [String] :fixture The name of the fixture to load in the
    #  fixtures folder relative to this file.
    # @option options [Hash] :model The model to generate code for. Defaults to
    #  a sample model.
    # @option options [String] :smithy The smithy version. Defaults to '2.0'.
    # @option options [Hash] :shapes The shapes to generate code for. Defaults to
    #  a sample set of shapes.
    # def sample(module_names, type, options = {})
    #   model = load_model(options)
    #   plan = create_plan(module_names, model, type, options)
    #   if options[:fixture]
    #     sourced_client(plan)
    #   else
    #     generated_client(plan)
    #   end
    # end

    def generate(type, options = {})
      model = load_model(options)
      options[:destination_root] ||= Dir.mktmpdir
      plan = create_plan(model, type, options)
      Smithy.generate(plan)
      plan
    end

    def source(type, options = {})
      model = load_model(options)
      # options[:module_name] ||= next_sample_module_name
      plan = create_plan(model, type, options)
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

    def create_plan(model, type, options = {})
      plan_options = {
        gem_version: '0.1.0',
        quiet: ENV.fetch('SMITHY_RUBY_QUIET', 'true') == 'true'
      }.merge(options)
      Smithy::Plan.new(model, type, plan_options)
    end

    def load_model(options)
      return load_fixture(options[:fixture]) if options[:fixture]

      options.fetch(:model, model(options))
    end

    def load_fixture(fixture)
      model_dir = File.join(File.dirname(__FILE__), '..', 'fixtures', fixture)
      JSON.load_file(File.join(model_dir, 'model.json'))
    end

    def model(options)
      {
        'smithy' => smithy(options),
        'shapes' => shapes(options)
      }
    end

    def smithy(options)
      options[:smithy] || '2.0'
    end

    def shapes(options)
      options[:shapes] || sample_shapes
    end

    # def next_sample_module_name
    #   @sample_client_count ||= 0
    #   @sample_client_count += 1
    #   "Sample#{@sample_client_count}"
    # end
  end
end
