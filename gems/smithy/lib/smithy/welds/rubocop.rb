# frozen_string_literal: true

module Smithy
  module Welds
    # Runs RuboCop autocorrect-all on the generated projections.
    class Rubocop < Weld
      TEST_NAMESPACES = [
        Regexp.new('smithy.tests.*?'),
        Regexp.new('smithy.ruby.tests.*?')
      ].freeze

      def for?(service)
        namespace = Model::Shape.namespace(service.keys.first).to_s
        TEST_NAMESPACES.none? { |test_namespace| namespace.match?(test_namespace) }
      end

      def post_process(_artifacts)
        require 'rubocop'
        puts "Running RuboCop --autocorrect-all on #{destination_root}"
        rubocop = ::RuboCop::CLI.new
        args = [
          '--autocorrect-all',
          '--display-only-fail-level-offenses',
          '--config',
          "#{destination_root}/.rubocop.yml",
          destination_root
        ]
        rubocop.run(args)
      end
    end
  end
end
