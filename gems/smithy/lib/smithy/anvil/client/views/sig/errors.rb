# frozen_string_literal: true

module Smithy
  module Anvil
    module Client
      module Views
        module Sig
          # Still its own class, but inherit from the regular view to reduce duplication
          class Errors < Errors
            # Add anything special the rbs view needs...
          end
        end
      end
    end
  end
end
