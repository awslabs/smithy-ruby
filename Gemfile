# frozen_string_literal: true

source 'https://rubygems.org'

gem 'hearth', path: './hearth'
gem 'jmespath'
gem 'rake', require: false
gem 'rexml'
gem 'http-2'

group :development do
  gem 'byebug'
  gem 'rbs'
  gem 'rubocop'
  gem 'rubocop-rake'
  gem 'steep'
end

group :docs do
  gem 'yard'
end

group :benchmark do
  gem 'memory_profiler'

  # required for uploading archive/metrics
  gem 'aws-sdk-cloudwatch'
  gem 'aws-sdk-s3'
end

group :test do
  gem 'rspec'
  gem 'simplecov'
  gem 'webmock'
end
