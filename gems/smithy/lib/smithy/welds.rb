# frozen_string_literal: true

require_relative 'welds/endpoints'
require_relative 'welds/plugins'
require_relative 'welds/rubocop'

module Smithy
  # @api private
  module Welds
    @welds = {}

    # Weld.subclasses should be ordered by insertion order. Reverse the order
    # to allow default welds to be overridden.
    def self.load!(plan)
      Weld.subclasses.reverse_each { |weld| @welds[weld] = weld.new(plan) }
    end

    def self.for(service)
      @welds.each_value.select { |weld| weld.for?(service) }
    end
  end
end
