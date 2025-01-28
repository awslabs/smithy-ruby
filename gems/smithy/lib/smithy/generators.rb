# frozen_string_literal: true

require_relative 'generators/base'
require_relative 'generators/client'
require_relative 'generators/schema'

module Smithy
  # Facilitates generation of artifacts.
  module Generators
    # Generates the artifact for the given plan.
    # @return [Array<String] The files that were generated.
    def self.generate(plan)
      case plan.type
      when :schema then Schema.new(plan).generate
      when :client then Client.new(plan).generate
      else
        raise 'Not yet implemented'
      end
    end

    # Generates the source files necessary for functionality and evaluates them.
    # @return [Object] The module that was generated.
    def self.source(plan)
      case plan.type
      when :schema then Schema.new(plan).source
      when :client then Client.new(plan).source
      else
        raise 'Not yet implemented'
      end
    end
  end
end
