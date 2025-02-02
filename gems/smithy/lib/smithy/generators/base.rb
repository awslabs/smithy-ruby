# frozen_string_literal: true

module Smithy
  module Generators
    # Base class for generating files.
    class Base
      include Thor::Base
      include Thor::Actions

      # @param [Plan] plan The plan to generate.
      def initialize(plan)
        # Necessary for Thor::Base and Thor::Actions
        self.options = { force: true, quiet: plan.quiet }
        self.destination_root = plan.destination_root
        shell.base = self
      end
    end
  end
end
