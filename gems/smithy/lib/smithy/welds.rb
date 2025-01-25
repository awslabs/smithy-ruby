# frozen_string_literal: true

require_relative 'welds/rubocop'

module Smithy
  # @api private
  module Welds
    @welds = {}

    def self.load!(plan)
      ObjectSpace
        .each_object(Class)
        .select { |klass| klass < Weld }
        .each { |weld| @welds[weld] = weld.new(plan) }
    end

    def self.for(service)
      @welds.each_value.select { |weld| weld.for?(service) }
    end
  end
end
