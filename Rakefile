# frozen_string_literal: true

require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RuboCop::RakeTask.new

namespace :smithy do
  RSpec::Core::RakeTask.new('spec:unit') do |t|
    t.pattern = 'gems/smithy/spec/**/*_spec.rb'
    t.ruby_opts = '-I gems/smithy/spec'
    t.rspec_opts = '--format documentation'
  end

  task 'spec:endpoints' do
    require_relative 'gems/smithy/spec/spec_helper'

    Dir.glob('gems/smithy/spec/fixtures/endpoints/*/model.json') do |model_path|
      test_name = model_path.split('/')[-2]
      puts "Building SDK for #{test_name} at: #{model_path}"
      tmpdir = SpecHelper.generate([test_name], :client, { fixture: "endpoints/#{test_name}" })
      sh("bundle exec rspec #{tmpdir}/spec -I #{tmpdir}/lib -I #{tmpdir}/spec")
    end
  end

  task 'spec' => %w[spec:unit spec:endpoints]
end

namespace 'smithy-client' do
  RSpec::Core::RakeTask.new do |t|
    t.pattern = 'gems/smithy-client/spec/**/*_spec.rb'
    t.ruby_opts = '-I gems/smithy-client/spec'
    t.rspec_opts = '--format documentation'
  end
end
