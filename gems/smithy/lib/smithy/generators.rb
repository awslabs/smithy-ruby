# frozen_string_literal: true

require_relative 'generators/base'
require_relative 'generators/client'
require_relative 'generators/schema'

module Smithy
  # Facilitates generation of artifacts.
  module Generators
    def self.generate(plan)
      case plan.type
      when :schema then Schema.new(plan).generate
      when :client then Client.new(plan).generate
      else
        raise 'Not yet implemented'
      end
    end

    def self.source(plan)
      case plan.type
      when :schema then Schema.new(plan).source
      when :client then Client.new(plan).source
      when :server then raise 'Will not be implemented'
      else
        raise 'Not yet implemented'
      end
    end
  end
end
