# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name         = 'smithy-client'
  spec.version      = File.read(File.expand_path('VERSION', __dir__)).strip
  spec.author       = 'Amazon Web Services'
  spec.summary      = 'Base runtime dependency for Smithy generated clients'
  spec.description  = 'Smithy is a code generation toolkit for creating Client and Server SDKs from Smithy models.'
  spec.homepage     = 'https://github.com/smithy-lang/smithy-ruby'
  spec.license      = 'Apache-2.0'
  spec.files        = Dir['CHANGELOG.md', 'VERSION', 'lib/**/*']

  spec.add_dependency('jmespath', '~> 1', '>= 1.6.1') # necessary for secure jmespath JSON parsing

  spec.required_ruby_version = '>= 3.0'
end
