# frozen_string_literal: true

module Smithy
  module Polishes
    # Runs RuboCop on the generated projections.
    class RuboCop < Polish
      EXCLUDED_COPS = [
        # Module name may have dashes based upon the gem name
        'Naming/FileName',
        # Generated code can be long or complex
        'Layout/LineLength',
        'Metrics/AbcSize',
        'Metrics/BlockLength',
        'Metrics/MethodLength',
        # TODO: fix this? map member in struct will override the map method.
        'Lint/StructNewOverride'
      ].freeze

      def polish(_artifact)
        require 'rubocop'
        puts "Running RuboCop on #{destination_root}"
        rubocop = ::RuboCop::CLI.new
        args = [
          '--autocorrect-all',
          '--fail-level',
          'info',
          '--except',
          EXCLUDED_COPS.join(','),
          '--display-only-fail-level-offenses',
          "#{destination_root}/lib/**/*.rb"
        ]
        status = rubocop.run(args)
        raise 'RuboCop failed' unless status.zero?
      end
    end
  end
end
