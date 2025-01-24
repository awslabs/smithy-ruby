# frozen_string_literal: true

require_relative 'generators/base'
require_relative 'generators/client'
require_relative 'generators/schema'

module Smithy
  # Facilitates generation of artifacts.
  module Generators
    # (see Smithy::Generators::Base#generate)
    def self.generate(plan)
      case plan.type
      when :schema then Schema.new(plan).generate
      when :client then Client.new(plan).generate
      else
        raise 'Not yet implemented'
      end
    end
  end
end
