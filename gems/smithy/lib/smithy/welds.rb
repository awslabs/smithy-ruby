# frozen_string_literal: true

require_relative 'welds/endpoints'

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

    def self.for(model)
      @welds.each_value.select { |weld| weld.for?(model) }
    end
  end
end
