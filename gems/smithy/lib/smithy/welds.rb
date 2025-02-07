# frozen_string_literal: true

require_relative 'welds/endpoints'
require_relative 'welds/plugins'
require_relative 'welds/rubocop'

module Smithy
  # @api private
  module Welds
    @welds = {}

    def self.load!(plan)
      Weld.subclasses.each { |weld| @welds[weld] = weld.new(plan) }
    end

    def self.for(service)
      @welds.each_value.select { |weld| weld.for?(service) }
    end
  end
end
