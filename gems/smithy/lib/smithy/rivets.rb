# frozen_string_literal: true

require_relative 'rivets/endpoints'
require_relative 'rivets/rubocop'

module Smithy
  # @api private
  module Rivets
    @rivets = {}

    def self.load!(plan)
      ObjectSpace
        .each_object(Class)
        .select { |klass| klass < Rivet }
        .each { |rivet| @rivets[rivet] = rivet.new(plan) }
    end

    def self.for(service)
      @rivets.each_value.select { |rivet| rivet.for?(service) }
    end
  end
end
