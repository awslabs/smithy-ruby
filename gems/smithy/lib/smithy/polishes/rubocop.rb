# frozen_string_literal: true

module Smithy
  module Polishes
    # Runs RuboCop on the generated projections.
    class RuboCop < Polish
      # TODO: maybe this can be a rubocop config file that is copied in to the gem?
      EXCLUDED_COPS = [
        'Gemspec/RequiredRubyVersion', # broken because of approach for running rubocop here
        'Style/Documentation', # We should add these but should ignore spec files
        # Module name may have dashes based upon the gem name
        'Naming/FileName',
        # Generated code can be long or complex
        'Layout/LineLength',
        'Metrics/AbcSize',
        'Metrics/BlockLength',
        'Metrics/MethodLength',
        'Metrics/ModuleLength',
        # TODO: fix this? map member in struct will override the map method.
        'Lint/StructNewOverride'
      ].freeze

      def polish(_artifact)
        require 'rubocop'
        puts "Running RuboCop on #{destination_root}"
        rubocop = ::RuboCop::CLI.new
        args = [
          '--autocorrect-all',
          '--except',
          EXCLUDED_COPS.join(','),
          '--display-only-fail-level-offenses',
          destination_root
        ]
        status = rubocop.run(args)
        raise 'RuboCop failed' unless status.zero?
      end
    end
  end
end
