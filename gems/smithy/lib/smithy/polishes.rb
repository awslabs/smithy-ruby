# frozen_string_literal: true

require_relative 'polishes/rubocop'

module Smithy
  # @api private
  module Polishes
    @polishes = {}

    def self.load!(plan)
      ObjectSpace
        .each_object(Class)
        .select { |klass| klass < Polish }
        .each { |polish| @polishes[polish] = polish.new(plan) }
    end

    def self.for(model)
      @polishes.each_value.select { |polish| polish.for?(model) }
    end
  end
end
