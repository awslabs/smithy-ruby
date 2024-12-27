# frozen_string_literal: true

module Smithy
  module Forge
    # Base class for generating files.
    class Base
      include Thor::Base
      include Thor::Actions

      # @param [Plan] plan The plan to forge.
      def initialize(plan)
        @plan = plan
        # Necessary for Thor::Base and Thor::Actions
        self.options = { force: true }
        self.destination_root = plan.options[:destination_root]
      end
    end
  end
end
