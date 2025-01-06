# frozen_string_literal: true

require_relative 'vise/shape'
require_relative 'vise/operation_parser'
require_relative 'vise/service_index'
require_relative 'vise/service_parser'
require_relative 'vise/structure_parser'

module Smithy
  # A module that parses the Smithy JSON model.
  module Vise
    PRELUDE_SHAPES = %w[
      smithy.api#BigInteger
      smithy.api#BigDecimal
      smithy.api#Blob
      smithy.api#Boolean
      smithy.api#Byte
      smithy.api#Document
      smithy.api#Double
      smithy.api#Float
      smithy.api#Integer
      smithy.api#Long
      smithy.api#PrimitiveBoolean
      smithy.api#PrimitiveByte
      smithy.api#PrimitiveDouble
      smithy.api#PrimitiveFloat
      smithy.api#PrimitiveInteger
      smithy.api#PrimitiveLong
      smithy.api#PrimitiveShort
      smithy.api#Short
      smithy.api#String
      smithy.api#Timestamp
      smithy.api#Unit
    ].freeze
  end
end
