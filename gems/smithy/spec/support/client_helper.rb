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

    def generate(module_names, type, options = {})
      model = load_fixture(options, module_names)
      plan_options = {
        module_name: module_names.join('::'),
        gem_version: options.fetch(:gem_version, '0.1.0'),
        destination_root: options.fetch(:destination_root, Dir.mktmpdir),
        quiet: ENV.fetch('SMITHY_RUBY_QUIET', 'true') == 'true'
      }
      plan = Smithy::Plan.new(model, type, plan_options)
      tmpdir = plan.destination_root
      Smithy.generate(plan)
      $LOAD_PATH << ("#{tmpdir}/lib")
      require plan.gem_name
      tmpdir
    end

    def cleanup_generated(module_names, tmpdir = nil)
      cleanup_sourced(module_names)
      return unless tmpdir

      if ENV.fetch('SMITHY_RUBY_KEEP_GENERATED_SOURCE', 'true') == 'true'
        puts "Leaving generated service in: #{tmpdir}"
      else
        FileUtils.rm_rf(tmpdir)
      end
      $LOAD_PATH.delete("#{tmpdir}/lib")
    end

    def source(type, options = {})
      model = options.delete(:model) || model(options)
      plan_options = {
        module_name: next_sample_module_name,
        gem_version: options.fetch(:gem_version, '0.1.0'),
        quiet: ENV.fetch('SMITHY_RUBY_QUIET', 'true') == 'true'
      }
      plan = Smithy::Plan.new(model, type, plan_options)
      source = Smithy.source(plan)
      Object.module_eval(source)
      Object.const_get(plan.module_name)
      [plan.module_name]
    rescue Exception => e # rubocop:disable Lint/RescueException
      puts "Error evaluating source:\n#{source}"
      raise e
    end

    def cleanup_sourced(module_names)
      module_names.reverse.each_cons(2) do |child, parent|
        Object.const_get(parent).send(:remove_const, child)
      end
      Object.send(:remove_const, module_names.first)
    end

    private

    def load_fixture(options, module_names)
      fixture = options.delete(:fixture) || module_names.map(&:underscore).join('/')
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
      options.delete(:smithy) || '2.0'
    end

    def shapes(options)
      options.delete(:shapes) || sample_shapes
    end

    def next_sample_module_name
      @sample_client_count ||= 0
      @sample_client_count += 1
      "Sample#{@sample_client_count}"
    end
  end
end
