# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name         = 'smithy'
  spec.version      = File.read(File.expand_path('VERSION', __dir__)).strip
  spec.author       = 'Amazon Web Services'
  spec.summary      = 'An SDK code generator for Smithy API models'
  spec.description  = 'Smithy is a code generation toolkit for creating Client and Server SDKs from Smithy models.'
  spec.homepage     = 'https://github.com/smithy-lang/smithy-ruby'
  spec.license      = 'Apache-2.0'
  spec.files        = Dir['CHANGELOG.md', 'VERSION', 'lib/**/*']
  spec.executables  = ['smithy-ruby']

  spec.add_dependency('railties', '~> 8.0')
  spec.add_dependency('rubocop')

  spec.required_ruby_version = '>= 3.3'
end
