# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rake', require: false

gem 'smithy', path: 'gems/smithy'
gem 'smithy-client', path: 'gems/smithy-client'
# gem 'smithy-server', path: 'gems/smithy-server'
gem 'smithy-model', path: 'gems/smithy-model'

group :development do
  gem 'byebug', platforms: :ruby
end

group :test do
  gem 'rspec'
  gem 'simplecov'
  gem 'webmock'
end

group :rbs do
  gem 'rbs', platforms: :ruby
  gem 'steep', platforms: :ruby
end

group :docs do
  gem 'yard'
  gem 'yard-sitemap', '~> 1.0'
end
