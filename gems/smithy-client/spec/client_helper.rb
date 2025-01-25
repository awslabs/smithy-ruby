# frozen_string_literal: true

module ClientHelper
  class << self
    def sample_shapes
      {
        # 'smithy.ruby.tests#StreamingBlob' => {
        #   'type' => 'blob',
        #   'traits' => { 'smithy.api#streaming' => {} }
        # },
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
            # 'document' => { 'target' => 'smithy.api#Document' },
            'double' => { 'target' => 'smithy.api#Double' },
            'enum' => { 'target' => 'smithy.ruby.tests#Enum' },
            'float' => { 'target' => 'smithy.api#Float' },
            'integer' => { 'target' => 'smithy.api#Integer' },
            'intEnum' => { 'target' => 'smithy.ruby.tests#intEnum' },
            'long' => { 'target' => 'smithy.api#Long' },
            'short' => { 'target' => 'smithy.api#Short' },
            'string' => { 'target' => 'smithy.api#String' },
            'timestamp' => { 'target' => 'smithy.api#Timestamp' },
            'structure' => { 'target' => 'smithy.ruby.tests#Structure' },
            'list' => { 'target' => 'smithy.ruby.tests#List' },
            'map' => { 'target' => 'smithy.ruby.tests#Map' }
            # 'union' => { 'target' => 'smithy.api#String' }
          }
        },
        'smithy.ruby.tests#Operation' => {
          'type' => 'operation',
          'input' => { 'target' => 'smithy.ruby.tests#Structure' },
          'output' => { 'target' => 'smithy.ruby.tests#Structure' }
        },
        'smithy.ruby.tests#SampleClient' => {
          'type' => 'service',
          'operations' => [
            { 'target' => 'smithy.ruby.tests#Operation' }
          ]
        }
      }
    end

    def sample_client(options = {})
      model = options[:model] ||= model(options)
      module_name = options[:gem_module] || next_sample_module_name
      plan = create_plan(module_name, model, options)

      source = source_code(plan)
      begin
        Object.module_eval(source)
      rescue StandardError => e
        puts source
        raise e
      end
      Object.const_get(module_name)
    end

    def sample_schema(options = {})
      sample_service(options).const_get(:Shapes).const_get(:Schema)
    end

    private

    def create_plan(module_name, model, options)
      plan_options = {
        gem_name: options[:gem_name] || 'sample',
        gem_version: options[:gem_version] || '1.0.0',
        gem_module: module_name
      }
      Smithy::Plan.new(model, :client, plan_options)
    end

    def source_code(plan)
      code = []
      Smithy::Generators::Client.new(plan).lib_files.each do |file_name, src_code|
        next if file_name.include? '/customizations.rb'
        next unless file_name.include? '/'

        code << src_code
      end
      code.join("\n")
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
      "SampleClient#{@sample_client_count}"
    end
  end
end
