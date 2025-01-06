# frozen_string_literal: true

module Smithy
  module Polishes
    # Runs RuboCop autocorrect-all on the generated projections.
    class RuboCop < Polish
      def polish(_artifact)
        require 'rubocop'
        puts "Running RuboCop --autocorrect-all on #{destination_root}"
        rubocop = ::RuboCop::CLI.new
        args = [
          '--autocorrect-all',
          '--display-only-fail-level-offenses',
          destination_root
        ]
        rubocop.run(args)
      end
    end
  end
end
