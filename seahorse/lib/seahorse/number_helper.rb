# frozen_string_literal: true

require 'time'

module Seahorse
  # A module that provides helper methods to convert from Time objects to
  # protocol specific serializable formats.
  # @api private
  module NumberHelper
    class << self
      # @param [Number,String] n
      # @return [String] The serialized number
      def serialize(input)
        if input == ::Float::INFINITY then 'Infinity'
        elsif input == -::Float::INFINITY then '-Infinity'
        elsif input&.nan? then 'NaN'
        else
          input
        end
      end

      # @param [String] str
      # @return [Number] The input as a number
      def deserialize(str)
        case str
        when 'Infinity' then ::Float::INFINITY
        when '-Infinity' then -::Float::INFINITY
        when 'NaN' then ::Float::NAN
        when nil then nil
        else str.to_f
        end
      end
    end
  end
end
