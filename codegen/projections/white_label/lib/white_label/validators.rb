# frozen_string_literal: true

# WARNING ABOUT GENERATED CODE
#
# This file was code generated using smithy-ruby.
# https://github.com/awslabs/smithy-ruby
#
# WARNING ABOUT GENERATED CODE

module WhiteLabel
  module Validators

    class ClientError
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::ClientError, context: context)
        Hearth::Validator.validate!(input[:message], ::String, context: "#{context}[:message]")
      end
    end

    class DefaultsTestInput
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::DefaultsTestInput, context: context)
        Hearth::Validator.validate!(input[:string], ::String, context: "#{context}[:string]")
        Hearth::Validator.validate!(input[:boxed_number], ::Integer, context: "#{context}[:boxed_number]")
        Hearth::Validator.validate!(input[:default_number], ::Integer, context: "#{context}[:default_number]")
        Hearth::Validator.validate!(input[:default_bool], ::TrueClass, ::FalseClass, context: "#{context}[:default_bool]")
      end
    end

    class DefaultsTestOutput
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::DefaultsTestOutput, context: context)
        Hearth::Validator.validate!(input[:string], ::String, context: "#{context}[:string]")
        Hearth::Validator.validate!(input[:boxed_number], ::Integer, context: "#{context}[:boxed_number]")
        Hearth::Validator.validate!(input[:default_number], ::Integer, context: "#{context}[:default_number]")
        Hearth::Validator.validate!(input[:default_bool], ::TrueClass, ::FalseClass, context: "#{context}[:default_bool]")
      end
    end

    class Document
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, ::Hash, ::String, ::Array, ::TrueClass, ::FalseClass, ::Numeric, context: context)
        case input
        when ::Hash
          input.each do |k,v|
            validate!(v, context: "#{context}[:#{k}]")
          end
        when ::Array
          input.each_with_index do |v, i|
            validate!(v, context: "#{context}[#{i}]")
          end
        end
      end
    end

    class EndpointOperationInput
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::EndpointOperationInput, context: context)
      end
    end

    class EndpointOperationOutput
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::EndpointOperationOutput, context: context)
      end
    end

    class EndpointWithHostLabelOperationInput
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::EndpointWithHostLabelOperationInput, context: context)
        Hearth::Validator.validate!(input[:label_member], ::String, context: "#{context}[:label_member]")
      end
    end

    class EndpointWithHostLabelOperationOutput
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::EndpointWithHostLabelOperationOutput, context: context)
      end
    end

    class Items
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, ::Array, context: context)
        input.each_with_index do |element, index|
          Hearth::Validator.validate!(element, ::String, context: "#{context}[#{index}]")
        end
      end
    end

    class KitchenSinkInput
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::KitchenSinkInput, context: context)
        Hearth::Validator.validate!(input[:string], ::String, context: "#{context}[:string]")
        Hearth::Validator.validate!(input[:simple_enum], ::String, context: "#{context}[:simple_enum]")
        Hearth::Validator.validate!(input[:typed_enum], ::String, context: "#{context}[:typed_enum]")
        Struct.validate!(input[:struct], context: "#{context}[:struct]") unless input[:struct].nil?
        Document.validate!(input[:document], context: "#{context}[:document]") unless input[:document].nil?
        ListOfStrings.validate!(input[:list_of_strings], context: "#{context}[:list_of_strings]") unless input[:list_of_strings].nil?
        ListOfStructs.validate!(input[:list_of_structs], context: "#{context}[:list_of_structs]") unless input[:list_of_structs].nil?
        MapOfStrings.validate!(input[:map_of_strings], context: "#{context}[:map_of_strings]") unless input[:map_of_strings].nil?
        MapOfStructs.validate!(input[:map_of_structs], context: "#{context}[:map_of_structs]") unless input[:map_of_structs].nil?
        Union.validate!(input[:union], context: "#{context}[:union]") unless input[:union].nil?
      end
    end

    class KitchenSinkOutput
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::KitchenSinkOutput, context: context)
        Hearth::Validator.validate!(input[:string], ::String, context: "#{context}[:string]")
        Hearth::Validator.validate!(input[:simple_enum], ::String, context: "#{context}[:simple_enum]")
        Hearth::Validator.validate!(input[:typed_enum], ::String, context: "#{context}[:typed_enum]")
        Struct.validate!(input[:struct], context: "#{context}[:struct]") unless input[:struct].nil?
        Document.validate!(input[:document], context: "#{context}[:document]") unless input[:document].nil?
        ListOfStrings.validate!(input[:list_of_strings], context: "#{context}[:list_of_strings]") unless input[:list_of_strings].nil?
        ListOfStructs.validate!(input[:list_of_structs], context: "#{context}[:list_of_structs]") unless input[:list_of_structs].nil?
        MapOfStrings.validate!(input[:map_of_strings], context: "#{context}[:map_of_strings]") unless input[:map_of_strings].nil?
        MapOfStructs.validate!(input[:map_of_structs], context: "#{context}[:map_of_structs]") unless input[:map_of_structs].nil?
        Union.validate!(input[:union], context: "#{context}[:union]") unless input[:union].nil?
      end
    end

    class ListOfStrings
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, ::Array, context: context)
        input.each_with_index do |element, index|
          Hearth::Validator.validate!(element, ::String, context: "#{context}[#{index}]")
        end
      end
    end

    class ListOfStructs
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, ::Array, context: context)
        input.each_with_index do |element, index|
          Struct.validate!(element, context: "#{context}[#{index}]") unless element.nil?
        end
      end
    end

    class MapOfStrings
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, ::Hash, context: context)
        input.each do |key, value|
          Hearth::Validator.validate!(key, ::String, ::Symbol, context: "#{context}.keys")
          Hearth::Validator.validate!(value, ::String, context: "#{context}[:#{key}]")
        end
      end
    end

    class MapOfStructs
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, ::Hash, context: context)
        input.each do |key, value|
          Hearth::Validator.validate!(key, ::String, ::Symbol, context: "#{context}.keys")
          Struct.validate!(value, context: "#{context}[:#{key}]") unless value.nil?
        end
      end
    end

    class PaginatorsTestOperationInput
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::PaginatorsTestOperationInput, context: context)
        Hearth::Validator.validate!(input[:next_token], ::String, context: "#{context}[:next_token]")
      end
    end

    class PaginatorsTestOperationOutput
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::PaginatorsTestOperationOutput, context: context)
        Hearth::Validator.validate!(input[:next_token], ::String, context: "#{context}[:next_token]")
        Items.validate!(input[:items], context: "#{context}[:items]") unless input[:items].nil?
      end
    end

    class PaginatorsTestWithItemsInput
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::PaginatorsTestWithItemsInput, context: context)
        Hearth::Validator.validate!(input[:next_token], ::String, context: "#{context}[:next_token]")
      end
    end

    class PaginatorsTestWithItemsOutput
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::PaginatorsTestWithItemsOutput, context: context)
        Hearth::Validator.validate!(input[:next_token], ::String, context: "#{context}[:next_token]")
        Items.validate!(input[:items], context: "#{context}[:items]") unless input[:items].nil?
      end
    end

    class ResultWrapper
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::ResultWrapper, context: context)
        Hearth::Validator.validate!(input[:member___123next_token], ::String, context: "#{context}[:member___123next_token]")
      end
    end

    class ServerError
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::ServerError, context: context)
      end
    end

    class StreamingOperationInput
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::StreamingOperationInput, context: context)
        unless input[:stream].respond_to?(:read) || input[:stream].respond_to?(:readpartial)
          raise ArgumentError, "Expected #{context} to be an IO like object, got #{input[:stream].class}"
        end
      end
    end

    class StreamingOperationOutput
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::StreamingOperationOutput, context: context)
        unless input[:stream].respond_to?(:read) || input[:stream].respond_to?(:readpartial)
          raise ArgumentError, "Expected #{context} to be an IO like object, got #{input[:stream].class}"
        end
      end
    end

    class StreamingWithLengthInput
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::StreamingWithLengthInput, context: context)
        unless input[:stream].respond_to?(:read) || input[:stream].respond_to?(:readpartial)
          raise ArgumentError, "Expected #{context} to be an IO like object, got #{input[:stream].class}"
        end

        unless input[:stream].respond_to?(:size)
          raise ArgumentError, "Expected #{context} to respond_to(:size)"
        end
      end
    end

    class StreamingWithLengthOutput
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::StreamingWithLengthOutput, context: context)
      end
    end

    class Struct
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::Struct, context: context)
        Hearth::Validator.validate!(input[:value], ::String, context: "#{context}[:value]")
      end
    end

    class Union
      def self.validate!(input, context:)
        case input
        when Types::Union::String
          Hearth::Validator.validate!(input.__getobj__, ::String, context: context)
        when Types::Union::Struct
          Struct.validate!(input.__getobj__, context: context) unless input.__getobj__.nil?
        else
          raise ArgumentError,
                "Expected #{context} to be a union member of "\
                "Types::Union, got #{input.class}."
        end
      end

      class String
        def self.validate!(input, context:)
          Hearth::Validator.validate!(input, ::String, context: context)
        end
      end

      class Struct
        def self.validate!(input, context:)
          Validators::Struct.validate!(input, context: context) unless input.nil?
        end
      end
    end

    class WaitersTestInput
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::WaitersTestInput, context: context)
        Hearth::Validator.validate!(input[:status], ::String, context: "#{context}[:status]")
      end
    end

    class WaitersTestOutput
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::WaitersTestOutput, context: context)
        Hearth::Validator.validate!(input[:status], ::String, context: "#{context}[:status]")
      end
    end

    class Struct____PaginatorsTestWithBadNamesInput
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::Struct____PaginatorsTestWithBadNamesInput, context: context)
        Hearth::Validator.validate!(input[:member___next_token], ::String, context: "#{context}[:member___next_token]")
      end
    end

    class Struct____PaginatorsTestWithBadNamesOutput
      def self.validate!(input, context:)
        Hearth::Validator.validate!(input, Types::Struct____PaginatorsTestWithBadNamesOutput, context: context)
        ResultWrapper.validate!(input[:member___wrapper], context: "#{context}[:member___wrapper]") unless input[:member___wrapper].nil?
        Items.validate!(input[:member___items], context: "#{context}[:member___items]") unless input[:member___items].nil?
      end
    end

  end
end
