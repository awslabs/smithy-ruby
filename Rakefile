# frozen_string_literal: true

require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RuboCop::RakeTask.new

# rubocop:disable Metrics/BlockLength
namespace :smithy do
  RSpec::Core::RakeTask.new('spec:unit') do |t|
    t.pattern = 'gems/smithy/spec/**/*_spec.rb'
    t.ruby_opts = '-I gems/smithy/spec'
    t.rspec_opts = '--format documentation'
  end

  task 'spec:endpoints' do
    require_relative 'gems/smithy/spec/spec_helper'

    spec_paths = []
    include_paths = []
    tmp_dirs = []
    Dir.glob('gems/smithy/spec/fixtures/endpoints/*/model.json') do |model_path|
      test_name = model_path.split('/')[-2]
      test_module = test_name.gsub('-', '').camelize
      tmpdir = SpecHelper.generate([test_module], :client, { fixture: "endpoints/#{test_name}" })
      tmp_dirs << [test_module.to_sym, tmpdir]
      spec_paths << "#{tmpdir}/spec"
      include_paths << "#{tmpdir}/lib"
      include_paths << "#{tmpdir}/spec"
    end
    specs = spec_paths.join(' ')
    includes = include_paths.map { |p| "-I #{p}" }.join(' ')
    sh("bundle exec rspec #{specs} #{includes}")
  ensure
    tmp_dirs.each do |name, tmpdir|
      SpecHelper.cleanup([name], tmpdir)
    end
  end

  task 'spec' => %w[spec:unit spec:endpoints]

  desc 'Convert all fixture smithy models to JSON AST representation.'
  task 'sync-fixtures' do
    Dir.glob('gems/smithy/spec/fixtures/**/model.smithy') do |model_path|
      out_path = model_path.sub('.smithy', '.json')
      sh("smithy ast --aut #{model_path} > #{out_path}")
    end
  end

  desc 'Validate that all fixtures JSON models are up to date.'
  task 'validate-fixtures' do
    require 'json'
    failures = []
    Dir.glob('gems/smithy/spec/fixtures/**/model.smithy') do |model_path|
      old = JSON.load_file(model_path.sub('.smithy', '.json'))
      new = JSON.parse(`smithy ast --aut #{model_path}`)
      failures << model_path if old != new
    end
    if failures.any?
      puts 'Fixture models out of sync:'
      failures.each { |m| puts "\t#{m}" }

      raise 'Fixture models are out of sync.  Run bundle exec rake smithy:sync-fixtures to correct'
    end
  end
end
# rubocop:enable Metrics/BlockLength

namespace 'smithy-client' do
  RSpec::Core::RakeTask.new do |t|
    t.pattern = 'gems/smithy-client/spec/**/*_spec.rb'
    t.ruby_opts = '-I gems/smithy-client/spec'
    t.rspec_opts = '--format documentation'
  end

  task 'rbs:validate' do
    sh('bundle exec rbs -I gems/smithy-client/sig validate')
  end

  task 'rbs:test' do
    env = {
      'RUBYOPT' => '-r bundler/setup -r rbs/test/setup',
      'RBS_TEST_RAISE' => 'true',
      'RBS_TEST_LOGLEVEL' => 'error',
      'RBS_TEST_OPT' => '-I gems/smithy-client/sig',
      'RBS_TEST_TARGET' => '"Smithy,Smithy::*,Smithy::Client"',
      'RBS_TEST_DOUBLE_SUITE' => 'rspec'
    }
    sh(env,
       'bundle exec rspec gems/smithy-client/spec -I gems/smithy-client/lib -I gems/smithy-client/spec ' \
       "--require spec_helper --tag '~rbs_test:skip'")
  end

  task 'rbs' => ['rbs:validate', 'rbs:test']
end
