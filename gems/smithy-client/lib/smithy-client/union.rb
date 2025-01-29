# frozen_string_literal: true

require 'delegate'

module Smithy
  module Client
    #  Top level class for all generated Union types
    class Union < ::SimpleDelegator
      include Structure

      def to_s
        "#<#{self.class.name} #{self.__getobj__ || 'nil'}>"
      end
    end
  end
end
