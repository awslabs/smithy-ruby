# frozen_string_literal: true

require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RuboCop::RakeTask.new

namespace :smithy do
  RSpec::Core::RakeTask.new do |t|
    t.pattern = 'gems/smithy/spec/**/*_spec.rb'
    t.ruby_opts = '-I gems/smithy/spec'
    t.rspec_opts = '--format documentation'
  end

  task 'spec:endpoints' do
    require 'smithy'
    require 'tmpdir'

    Dir.glob('gems/smithy/spec/fixtures/endpoints/*/model.json') do |model_path|
      Dir.mktmpdir do |tmp_dir|
        test_name = model_path.split('/')[-2]
        gem_name = test_name.gsub('-', '')
        puts "Building SDK for #{test_name} at: #{model_path}"
        model = JSON.load_file(model_path)

        plan = Smithy::Plan.new(model, :client, {
          gem_name: gem_name,
          gem_version: '1.0.0',
          destination_root: tmp_dir
        })
        Smithy.smith(plan)

        sh("bundle exec rspec #{tmp_dir}/spec -I #{tmp_dir}/lib -I #{tmp_dir}/spec")
      end
    end
  end
end

namespace 'smithy-client' do
  RSpec::Core::RakeTask.new do |t|
    t.pattern = 'gems/smithy-client/spec/**/*_spec.rb'
    t.ruby_opts = '-I gems/smithy-client/spec'
    t.rspec_opts = '--format documentation'
  end
end
