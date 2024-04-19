# frozen_string_literal: true

# WARNING ABOUT GENERATED CODE
#
# This file was code generated using smithy-ruby.
# https://github.com/smithy-lang/smithy-ruby
#
# WARNING ABOUT GENERATED CODE

require 'base64'

module RailsJson
  # @api private
  module Parsers

    class AllQueryStringTypes
      def self.parse(http_resp)
        data = Types::AllQueryStringTypesOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class BooleanList
      def self.parse(list)
        list.map do |value|
          value unless value.nil?
        end
      end
    end

    # Error Parser for ComplexError
    class ComplexError
      def self.parse(http_resp)
        data = Types::ComplexError.new
        data.header = http_resp.headers['X-Header']
        map = Hearth::JSON.parse(http_resp.body.read)
        data.top_level = map['top_level']
        data.nested = (Parsers::ComplexNestedErrorData.parse(map['nested']) unless map['nested'].nil?)
        data
      end
    end

    class ComplexNestedErrorData
      def self.parse(map)
        data = Types::ComplexNestedErrorData.new
        data.foo = map['Fooooo']
        return data
      end
    end

    class ConstantAndVariableQueryString
      def self.parse(http_resp)
        data = Types::ConstantAndVariableQueryStringOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class ConstantQueryString
      def self.parse(http_resp)
        data = Types::ConstantQueryStringOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class DatetimeOffsets
      def self.parse(http_resp)
        data = Types::DatetimeOffsetsOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data.datetime = Time.parse(map['datetime']) if map['datetime']
        data
      end
    end

    class DenseBooleanMap
      def self.parse(map)
        data = {}
        map.map do |key, value|
          data[key] = value unless value.nil?
        end
        data
      end
    end

    class DenseNumberMap
      def self.parse(map)
        data = {}
        map.map do |key, value|
          data[key] = value unless value.nil?
        end
        data
      end
    end

    class DenseSetMap
      def self.parse(map)
        data = {}
        map.map do |key, value|
          data[key] = Parsers::StringSet.parse(value) unless value.nil?
        end
        data
      end
    end

    class DenseStringMap
      def self.parse(map)
        data = {}
        map.map do |key, value|
          data[key] = value unless value.nil?
        end
        data
      end
    end

    class DenseStructMap
      def self.parse(map)
        data = {}
        map.map do |key, value|
          data[key] = Parsers::GreetingStruct.parse(value) unless value.nil?
        end
        data
      end
    end

    class DocumentType
      def self.parse(http_resp)
        data = Types::DocumentTypeOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data.string_value = map['string_value']
        data.document_value = map['document_value']
        data
      end
    end

    class DocumentTypeAsMapValue
      def self.parse(http_resp)
        data = Types::DocumentTypeAsMapValueOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data.doc_valued_map = (Parsers::DocumentValuedMap.parse(map['doc_valued_map']) unless map['doc_valued_map'].nil?)
        data
      end
    end

    class DocumentTypeAsPayload
      def self.parse(http_resp)
        data = Types::DocumentTypeAsPayloadOutput.new
        payload = Hearth::JSON.parse(http_resp.body.read)
        data.document_value = payload
        data
      end
    end

    class DocumentValuedMap
      def self.parse(map)
        data = {}
        map.map do |key, value|
          data[key] = value unless value.nil?
        end
        data
      end
    end

    class EmptyInputAndEmptyOutput
      def self.parse(http_resp)
        data = Types::EmptyInputAndEmptyOutputOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class EndpointOperation
      def self.parse(http_resp)
        data = Types::EndpointOperationOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class EndpointWithHostLabelOperation
      def self.parse(http_resp)
        data = Types::EndpointWithHostLabelOperationOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class FooEnumList
      def self.parse(list)
        list.map do |value|
          value unless value.nil?
        end
      end
    end

    class FooEnumMap
      def self.parse(map)
        data = {}
        map.map do |key, value|
          data[key] = value unless value.nil?
        end
        data
      end
    end

    class FooEnumSet
      def self.parse(list)
        list.map do |value|
          value unless value.nil?
        end
      end
    end

    # Error Parser for FooError
    class FooError
      def self.parse(http_resp)
        data = Types::FooError.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class FractionalSeconds
      def self.parse(http_resp)
        data = Types::FractionalSecondsOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data.datetime = Time.parse(map['datetime']) if map['datetime']
        data
      end
    end

    class GreetingStruct
      def self.parse(map)
        data = Types::GreetingStruct.new
        data.hi = map['hi']
        return data
      end
    end

    class RenamedGreeting
      def self.parse(map)
        data = Types::RenamedGreeting.new
        data.salutation = map['salutation']
        return data
      end
    end

    class GreetingWithErrors
      def self.parse(http_resp)
        data = Types::GreetingWithErrorsOutput.new
        data.greeting = http_resp.headers['X-Greeting']
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class HostWithPathOperation
      def self.parse(http_resp)
        data = Types::HostWithPathOperationOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class HttpChecksumRequired
      def self.parse(http_resp)
        data = Types::HttpChecksumRequiredOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data.foo = map['foo']
        data
      end
    end

    class HttpEnumPayload
      def self.parse(http_resp)
        data = Types::HttpEnumPayloadOutput.new
        payload = http_resp.body.read
        data.payload = payload unless payload.empty?
        data
      end
    end

    class HttpPayloadTraits
      def self.parse(http_resp)
        data = Types::HttpPayloadTraitsOutput.new
        data.foo = http_resp.headers['X-Foo']
        payload = http_resp.body.read
        data.blob = payload unless payload.empty?
        data
      end
    end

    class HttpPayloadTraitsWithMediaType
      def self.parse(http_resp)
        data = Types::HttpPayloadTraitsWithMediaTypeOutput.new
        data.foo = http_resp.headers['X-Foo']
        payload = http_resp.body.read
        data.blob = payload unless payload.empty?
        data
      end
    end

    class HttpPayloadWithStructure
      def self.parse(http_resp)
        data = Types::HttpPayloadWithStructureOutput.new
        json = Hearth::JSON.parse(http_resp.body.read)
        data.nested = Parsers::NestedPayload.parse(json)
        data
      end
    end

    class HttpPayloadWithUnion
      def self.parse(http_resp)
        data = Types::HttpPayloadWithUnionOutput.new
        json = Hearth::JSON.parse(http_resp.body.read)
        data.nested = Parsers::UnionPayload.parse(json)
        data
      end
    end

    class HttpPrefixHeaders
      def self.parse(http_resp)
        data = Types::HttpPrefixHeadersOutput.new
        data.foo = http_resp.headers['X-Foo']
        data.foo_map = {}
        http_resp.headers.each do |key, value|
          if key.start_with?('X-Foo-')
            data.foo_map[key.delete_prefix('X-Foo-')] = value
          end
        end
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class HttpPrefixHeadersInResponse
      def self.parse(http_resp)
        data = Types::HttpPrefixHeadersInResponseOutput.new
        data.prefix_headers = {}
        http_resp.headers.each do |key, value|
          if key.start_with?('')
            data.prefix_headers[key.delete_prefix('')] = value
          end
        end
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class HttpRequestWithFloatLabels
      def self.parse(http_resp)
        data = Types::HttpRequestWithFloatLabelsOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class HttpRequestWithGreedyLabelInPath
      def self.parse(http_resp)
        data = Types::HttpRequestWithGreedyLabelInPathOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class HttpRequestWithLabels
      def self.parse(http_resp)
        data = Types::HttpRequestWithLabelsOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class HttpRequestWithLabelsAndTimestampFormat
      def self.parse(http_resp)
        data = Types::HttpRequestWithLabelsAndTimestampFormatOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class HttpRequestWithRegexLiteral
      def self.parse(http_resp)
        data = Types::HttpRequestWithRegexLiteralOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class HttpResponseCode
      def self.parse(http_resp)
        data = Types::HttpResponseCodeOutput.new
        data.status = http_resp.status
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class HttpStringPayload
      def self.parse(http_resp)
        data = Types::HttpStringPayloadOutput.new
        payload = http_resp.body.read
        data.payload = payload unless payload.empty?
        data
      end
    end

    class IgnoreQueryParamsInResponse
      def self.parse(http_resp)
        data = Types::IgnoreQueryParamsInResponseOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class InputAndOutputWithHeaders
      def self.parse(http_resp)
        data = Types::InputAndOutputWithHeadersOutput.new
        data.header_string = http_resp.headers['X-String']
        data.header_byte = http_resp.headers['X-Byte'].to_i unless http_resp.headers['X-Byte'].nil?
        data.header_short = http_resp.headers['X-Short'].to_i unless http_resp.headers['X-Short'].nil?
        data.header_integer = http_resp.headers['X-Integer'].to_i unless http_resp.headers['X-Integer'].nil?
        data.header_long = http_resp.headers['X-Long'].to_i unless http_resp.headers['X-Long'].nil?
        data.header_float = Hearth::NumberHelper.deserialize(http_resp.headers['X-Float']) unless http_resp.headers['X-Float'].nil?
        data.header_double = Hearth::NumberHelper.deserialize(http_resp.headers['X-Double']) unless http_resp.headers['X-Double'].nil?
        data.header_true_bool = http_resp.headers['X-Boolean1'] == 'true' unless http_resp.headers['X-Boolean1'].nil?
        data.header_false_bool = http_resp.headers['X-Boolean2'] == 'true' unless http_resp.headers['X-Boolean2'].nil?
        unless http_resp.headers['X-StringList'].nil? || http_resp.headers['X-StringList'].empty?
          data.header_string_list = Hearth::Http::HeaderListParser.parse_string_list(http_resp.headers['X-StringList'])
        end
        unless http_resp.headers['X-StringSet'].nil? || http_resp.headers['X-StringSet'].empty?
          data.header_string_set = Hearth::Http::HeaderListParser.parse_string_list(http_resp.headers['X-StringSet'])
        end
        unless http_resp.headers['X-IntegerList'].nil? || http_resp.headers['X-IntegerList'].empty?
          data.header_integer_list = http_resp.headers['X-IntegerList']
            .split(', ')
            .map { |s| s.to_i }
        end
        unless http_resp.headers['X-BooleanList'].nil? || http_resp.headers['X-BooleanList'].empty?
          data.header_boolean_list = http_resp.headers['X-BooleanList']
            .split(', ')
            .map { |s| s == 'true' }
        end
        unless http_resp.headers['X-TimestampList'].nil? || http_resp.headers['X-TimestampList'].empty?
          data.header_timestamp_list = Hearth::Http::HeaderListParser.parse_http_date_list(http_resp.headers['X-TimestampList'])
        end
        data.header_enum = http_resp.headers['X-Enum']
        unless http_resp.headers['X-EnumList'].nil? || http_resp.headers['X-EnumList'].empty?
          data.header_enum_list = Hearth::Http::HeaderListParser.parse_string_list(http_resp.headers['X-EnumList'])
        end
        data.header_integer_enum = http_resp.headers['X-IntegerEnum'].to_i unless http_resp.headers['X-IntegerEnum'].nil?
        unless http_resp.headers['X-IntegerEnumList'].nil? || http_resp.headers['X-IntegerEnumList'].empty?
          data.header_integer_enum_list = http_resp.headers['X-IntegerEnumList']
            .split(', ')
            .map { |s| s.to_i }
        end
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class IntegerEnumList
      def self.parse(list)
        list.map do |value|
          value unless value.nil?
        end
      end
    end

    class IntegerEnumMap
      def self.parse(map)
        data = {}
        map.map do |key, value|
          data[key] = value unless value.nil?
        end
        data
      end
    end

    class IntegerEnumSet
      def self.parse(list)
        list.map do |value|
          value unless value.nil?
        end
      end
    end

    class IntegerList
      def self.parse(list)
        list.map do |value|
          value unless value.nil?
        end
      end
    end

    # Error Parser for InvalidGreeting
    class InvalidGreeting
      def self.parse(http_resp)
        data = Types::InvalidGreeting.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data.message = map['message']
        data
      end
    end

    class JsonBlobs
      def self.parse(http_resp)
        data = Types::JsonBlobsOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data.data = ::Base64::decode64(map['data']) unless map['data'].nil?
        data
      end
    end

    class JsonEnums
      def self.parse(http_resp)
        data = Types::JsonEnumsOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data.foo_enum1 = map['foo_enum1']
        data.foo_enum2 = map['foo_enum2']
        data.foo_enum3 = map['foo_enum3']
        data.foo_enum_list = (Parsers::FooEnumList.parse(map['foo_enum_list']) unless map['foo_enum_list'].nil?)
        data.foo_enum_set = (Parsers::FooEnumSet.parse(map['foo_enum_set']) unless map['foo_enum_set'].nil?)
        data.foo_enum_map = (Parsers::FooEnumMap.parse(map['foo_enum_map']) unless map['foo_enum_map'].nil?)
        data
      end
    end

    class JsonIntEnums
      def self.parse(http_resp)
        data = Types::JsonIntEnumsOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data.integer_enum1 = map['integer_enum1']
        data.integer_enum2 = map['integer_enum2']
        data.integer_enum3 = map['integer_enum3']
        data.integer_enum_list = (Parsers::IntegerEnumList.parse(map['integer_enum_list']) unless map['integer_enum_list'].nil?)
        data.integer_enum_set = (Parsers::IntegerEnumSet.parse(map['integer_enum_set']) unless map['integer_enum_set'].nil?)
        data.integer_enum_map = (Parsers::IntegerEnumMap.parse(map['integer_enum_map']) unless map['integer_enum_map'].nil?)
        data
      end
    end

    class JsonLists
      def self.parse(http_resp)
        data = Types::JsonListsOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data.string_list = (Parsers::StringList.parse(map['string_list']) unless map['string_list'].nil?)
        data.string_set = (Parsers::StringSet.parse(map['string_set']) unless map['string_set'].nil?)
        data.integer_list = (Parsers::IntegerList.parse(map['integer_list']) unless map['integer_list'].nil?)
        data.boolean_list = (Parsers::BooleanList.parse(map['boolean_list']) unless map['boolean_list'].nil?)
        data.timestamp_list = (Parsers::TimestampList.parse(map['timestamp_list']) unless map['timestamp_list'].nil?)
        data.enum_list = (Parsers::FooEnumList.parse(map['enum_list']) unless map['enum_list'].nil?)
        data.int_enum_list = (Parsers::IntegerEnumList.parse(map['int_enum_list']) unless map['int_enum_list'].nil?)
        data.nested_string_list = (Parsers::NestedStringList.parse(map['nested_string_list']) unless map['nested_string_list'].nil?)
        data.structure_list = (Parsers::StructureList.parse(map['myStructureList']) unless map['myStructureList'].nil?)
        data
      end
    end

    class JsonMaps
      def self.parse(http_resp)
        data = Types::JsonMapsOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data.dense_struct_map = (Parsers::DenseStructMap.parse(map['dense_struct_map']) unless map['dense_struct_map'].nil?)
        data.dense_number_map = (Parsers::DenseNumberMap.parse(map['dense_number_map']) unless map['dense_number_map'].nil?)
        data.dense_boolean_map = (Parsers::DenseBooleanMap.parse(map['dense_boolean_map']) unless map['dense_boolean_map'].nil?)
        data.dense_string_map = (Parsers::DenseStringMap.parse(map['dense_string_map']) unless map['dense_string_map'].nil?)
        data.dense_set_map = (Parsers::DenseSetMap.parse(map['dense_set_map']) unless map['dense_set_map'].nil?)
        data
      end
    end

    class JsonTimestamps
      def self.parse(http_resp)
        data = Types::JsonTimestampsOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data.normal = Time.parse(map['normal']) if map['normal']
        data.date_time = Time.parse(map['date_time']) if map['date_time']
        data.date_time_on_target = Time.parse(map['date_time_on_target']) if map['date_time_on_target']
        data.epoch_seconds = Time.at(map['epoch_seconds'].to_i) if map['epoch_seconds']
        data.epoch_seconds_on_target = Time.at(map['epoch_seconds_on_target'].to_i) if map['epoch_seconds_on_target']
        data.http_date = Time.parse(map['http_date']) if map['http_date']
        data.http_date_on_target = Time.parse(map['http_date_on_target']) if map['http_date_on_target']
        data
      end
    end

    class JsonUnions
      def self.parse(http_resp)
        data = Types::JsonUnionsOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data.contents = (Parsers::MyUnion.parse(map['contents']) unless map['contents'].nil?)
        data
      end
    end

    class MalformedAcceptWithBody
      def self.parse(http_resp)
        data = Types::MalformedAcceptWithBodyOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data.hi = map['hi']
        data
      end
    end

    class MalformedAcceptWithGenericString
      def self.parse(http_resp)
        data = Types::MalformedAcceptWithGenericStringOutput.new
        payload = http_resp.body.read
        data.payload = payload unless payload.empty?
        data
      end
    end

    class MalformedAcceptWithPayload
      def self.parse(http_resp)
        data = Types::MalformedAcceptWithPayloadOutput.new
        payload = http_resp.body.read
        data.payload = payload unless payload.empty?
        data
      end
    end

    class MalformedBlob
      def self.parse(http_resp)
        data = Types::MalformedBlobOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedBoolean
      def self.parse(http_resp)
        data = Types::MalformedBooleanOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedByte
      def self.parse(http_resp)
        data = Types::MalformedByteOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedContentTypeWithBody
      def self.parse(http_resp)
        data = Types::MalformedContentTypeWithBodyOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedContentTypeWithGenericString
      def self.parse(http_resp)
        data = Types::MalformedContentTypeWithGenericStringOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedContentTypeWithPayload
      def self.parse(http_resp)
        data = Types::MalformedContentTypeWithPayloadOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedContentTypeWithoutBody
      def self.parse(http_resp)
        data = Types::MalformedContentTypeWithoutBodyOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedDouble
      def self.parse(http_resp)
        data = Types::MalformedDoubleOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedFloat
      def self.parse(http_resp)
        data = Types::MalformedFloatOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedInteger
      def self.parse(http_resp)
        data = Types::MalformedIntegerOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedList
      def self.parse(http_resp)
        data = Types::MalformedListOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedLong
      def self.parse(http_resp)
        data = Types::MalformedLongOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedMap
      def self.parse(http_resp)
        data = Types::MalformedMapOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedRequestBody
      def self.parse(http_resp)
        data = Types::MalformedRequestBodyOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedShort
      def self.parse(http_resp)
        data = Types::MalformedShortOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedString
      def self.parse(http_resp)
        data = Types::MalformedStringOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedTimestampBodyDateTime
      def self.parse(http_resp)
        data = Types::MalformedTimestampBodyDateTimeOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedTimestampBodyDefault
      def self.parse(http_resp)
        data = Types::MalformedTimestampBodyDefaultOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedTimestampBodyHttpDate
      def self.parse(http_resp)
        data = Types::MalformedTimestampBodyHttpDateOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedTimestampHeaderDateTime
      def self.parse(http_resp)
        data = Types::MalformedTimestampHeaderDateTimeOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedTimestampHeaderDefault
      def self.parse(http_resp)
        data = Types::MalformedTimestampHeaderDefaultOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedTimestampHeaderEpoch
      def self.parse(http_resp)
        data = Types::MalformedTimestampHeaderEpochOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedTimestampPathDefault
      def self.parse(http_resp)
        data = Types::MalformedTimestampPathDefaultOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedTimestampPathEpoch
      def self.parse(http_resp)
        data = Types::MalformedTimestampPathEpochOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedTimestampPathHttpDate
      def self.parse(http_resp)
        data = Types::MalformedTimestampPathHttpDateOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedTimestampQueryDefault
      def self.parse(http_resp)
        data = Types::MalformedTimestampQueryDefaultOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedTimestampQueryEpoch
      def self.parse(http_resp)
        data = Types::MalformedTimestampQueryEpochOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedTimestampQueryHttpDate
      def self.parse(http_resp)
        data = Types::MalformedTimestampQueryHttpDateOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MalformedUnion
      def self.parse(http_resp)
        data = Types::MalformedUnionOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MediaTypeHeader
      def self.parse(http_resp)
        data = Types::MediaTypeHeaderOutput.new
        data.json = ::Base64::decode64(http_resp.headers['X-Json']).strip unless http_resp.headers['X-Json'].nil?
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class MyUnion
      def self.parse(map)
        key, value = map.flatten
        case key
        when 'string_value'
          value = value
          Types::MyUnion::StringValue.new(value) if value
        when 'boolean_value'
          value = value
          Types::MyUnion::BooleanValue.new(value) if value
        when 'number_value'
          value = value
          Types::MyUnion::NumberValue.new(value) if value
        when 'blob_value'
          value = ::Base64::decode64(value) unless value.nil?
          Types::MyUnion::BlobValue.new(value) if value
        when 'timestamp_value'
          value = Time.parse(value) if value
          Types::MyUnion::TimestampValue.new(value) if value
        when 'enum_value'
          value = value
          Types::MyUnion::EnumValue.new(value) if value
        when 'list_value'
          value = (Parsers::StringList.parse(value) unless value.nil?)
          Types::MyUnion::ListValue.new(value) if value
        when 'map_value'
          value = (Parsers::StringMap.parse(value) unless value.nil?)
          Types::MyUnion::MapValue.new(value) if value
        when 'structure_value'
          value = (Parsers::GreetingStruct.parse(value) unless value.nil?)
          Types::MyUnion::StructureValue.new(value) if value
        when 'renamed_structure_value'
          value = (Parsers::RenamedGreeting.parse(value) unless value.nil?)
          Types::MyUnion::RenamedStructureValue.new(value) if value
        else
          Types::MyUnion::Unknown.new(name: key, value: value)
        end
      end
    end

    class NestedPayload
      def self.parse(map)
        data = Types::NestedPayload.new
        data.greeting = map['greeting']
        data.name = map['name']
        return data
      end
    end

    class NestedStringList
      def self.parse(list)
        list.map do |value|
          Parsers::StringList.parse(value) unless value.nil?
        end
      end
    end

    class NoInputAndNoOutput
      def self.parse(http_resp)
        data = Types::NoInputAndNoOutputOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class NoInputAndOutput
      def self.parse(http_resp)
        data = Types::NoInputAndOutputOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class NullAndEmptyHeadersClient
      def self.parse(http_resp)
        data = Types::NullAndEmptyHeadersClientOutput.new
        data.a = http_resp.headers['X-A']
        data.b = http_resp.headers['X-B']
        unless http_resp.headers['X-C'].nil? || http_resp.headers['X-C'].empty?
          data.c = Hearth::Http::HeaderListParser.parse_string_list(http_resp.headers['X-C'])
        end
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class NullAndEmptyHeadersServer
      def self.parse(http_resp)
        data = Types::NullAndEmptyHeadersServerOutput.new
        data.a = http_resp.headers['X-A']
        data.b = http_resp.headers['X-B']
        unless http_resp.headers['X-C'].nil? || http_resp.headers['X-C'].empty?
          data.c = Hearth::Http::HeaderListParser.parse_string_list(http_resp.headers['X-C'])
        end
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class OmitsNullSerializesEmptyString
      def self.parse(http_resp)
        data = Types::OmitsNullSerializesEmptyStringOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class OmitsSerializingEmptyLists
      def self.parse(http_resp)
        data = Types::OmitsSerializingEmptyListsOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class PayloadConfig
      def self.parse(map)
        data = Types::PayloadConfig.new
        data.data = map['data']
        return data
      end
    end

    class PlayerAction
      def self.parse(map)
        key, value = map.flatten
        case key
        when 'quit'
          value = (Parsers::Unit.parse(value) unless value.nil?)
          Types::PlayerAction::Quit.new(value) if value
        else
          Types::PlayerAction::Unknown.new(name: key, value: value)
        end
      end
    end

    class PostPlayerAction
      def self.parse(http_resp)
        data = Types::PostPlayerActionOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data.action = (Parsers::PlayerAction.parse(map['action']) unless map['action'].nil?)
        data
      end
    end

    class PostUnionWithJsonName
      def self.parse(http_resp)
        data = Types::PostUnionWithJsonNameOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data.value = (Parsers::UnionWithJsonName.parse(map['value']) unless map['value'].nil?)
        data
      end
    end

    class PutWithContentEncoding
      def self.parse(http_resp)
        data = Types::PutWithContentEncodingOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class QueryIdempotencyTokenAutoFill
      def self.parse(http_resp)
        data = Types::QueryIdempotencyTokenAutoFillOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class QueryParamsAsStringListMap
      def self.parse(http_resp)
        data = Types::QueryParamsAsStringListMapOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class QueryPrecedence
      def self.parse(http_resp)
        data = Types::QueryPrecedenceOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class RecursiveShapes
      def self.parse(http_resp)
        data = Types::RecursiveShapesOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data.nested = (Parsers::RecursiveShapesInputOutputNested1.parse(map['nested']) unless map['nested'].nil?)
        data
      end
    end

    class RecursiveShapesInputOutputNested1
      def self.parse(map)
        data = Types::RecursiveShapesInputOutputNested1.new
        data.foo = map['foo']
        data.nested = (Parsers::RecursiveShapesInputOutputNested2.parse(map['nested']) unless map['nested'].nil?)
        return data
      end
    end

    class RecursiveShapesInputOutputNested2
      def self.parse(map)
        data = Types::RecursiveShapesInputOutputNested2.new
        data.bar = map['bar']
        data.recursive_member = (Parsers::RecursiveShapesInputOutputNested1.parse(map['recursive_member']) unless map['recursive_member'].nil?)
        return data
      end
    end

    class SimpleScalarProperties
      def self.parse(http_resp)
        data = Types::SimpleScalarPropertiesOutput.new
        data.foo = http_resp.headers['X-Foo']
        map = Hearth::JSON.parse(http_resp.body.read)
        data.string_value = map['string_value']
        data.true_boolean_value = map['true_boolean_value']
        data.false_boolean_value = map['false_boolean_value']
        data.byte_value = map['byte_value']
        data.short_value = map['short_value']
        data.integer_value = map['integer_value']
        data.long_value = map['long_value']
        data.float_value = Hearth::NumberHelper.deserialize(map['float_value'])
        data.double_value = Hearth::NumberHelper.deserialize(map['DoubleDribble'])
        data
      end
    end

    class SparseBooleanMap
      def self.parse(map)
        data = {}
        map.map do |key, value|
          data[key] = value
        end
        data
      end
    end

    class SparseJsonLists
      def self.parse(http_resp)
        data = Types::SparseJsonListsOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data.sparse_string_list = (Parsers::SparseStringList.parse(map['sparse_string_list']) unless map['sparse_string_list'].nil?)
        data
      end
    end

    class SparseJsonMaps
      def self.parse(http_resp)
        data = Types::SparseJsonMapsOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data.sparse_struct_map = (Parsers::SparseStructMap.parse(map['sparse_struct_map']) unless map['sparse_struct_map'].nil?)
        data.sparse_number_map = (Parsers::SparseNumberMap.parse(map['sparse_number_map']) unless map['sparse_number_map'].nil?)
        data.sparse_boolean_map = (Parsers::SparseBooleanMap.parse(map['sparse_boolean_map']) unless map['sparse_boolean_map'].nil?)
        data.sparse_string_map = (Parsers::SparseStringMap.parse(map['sparse_string_map']) unless map['sparse_string_map'].nil?)
        data.sparse_set_map = (Parsers::SparseSetMap.parse(map['sparse_set_map']) unless map['sparse_set_map'].nil?)
        data
      end
    end

    class SparseNumberMap
      def self.parse(map)
        data = {}
        map.map do |key, value|
          data[key] = value
        end
        data
      end
    end

    class SparseSetMap
      def self.parse(map)
        data = {}
        map.map do |key, value|
          data[key] = (Parsers::StringSet.parse(value) unless value.nil?)
        end
        data
      end
    end

    class SparseStringList
      def self.parse(list)
        list.map do |value|
          value
        end
      end
    end

    class SparseStringMap
      def self.parse(map)
        data = {}
        map.map do |key, value|
          data[key] = value
        end
        data
      end
    end

    class SparseStructMap
      def self.parse(map)
        data = {}
        map.map do |key, value|
          data[key] = (Parsers::GreetingStruct.parse(value) unless value.nil?)
        end
        data
      end
    end

    class StreamingTraits
      def self.parse(http_resp)
        data = Types::StreamingTraitsOutput.new
        data.foo = http_resp.headers['X-Foo']
        data.blob = http_resp.body
        data
      end
    end

    class StreamingTraitsRequireLength
      def self.parse(http_resp)
        data = Types::StreamingTraitsRequireLengthOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class StreamingTraitsWithMediaType
      def self.parse(http_resp)
        data = Types::StreamingTraitsWithMediaTypeOutput.new
        data.foo = http_resp.headers['X-Foo']
        data.blob = http_resp.body
        data
      end
    end

    class StringList
      def self.parse(list)
        list.map do |value|
          value unless value.nil?
        end
      end
    end

    class StringMap
      def self.parse(map)
        data = {}
        map.map do |key, value|
          data[key] = value unless value.nil?
        end
        data
      end
    end

    class StringSet
      def self.parse(list)
        list.map do |value|
          value unless value.nil?
        end
      end
    end

    class StructureList
      def self.parse(list)
        list.map do |value|
          Parsers::StructureListMember.parse(value) unless value.nil?
        end
      end
    end

    class StructureListMember
      def self.parse(map)
        data = Types::StructureListMember.new
        data.a = map['value']
        data.b = map['other']
        return data
      end
    end

    class TestBodyStructure
      def self.parse(http_resp)
        data = Types::TestBodyStructureOutput.new
        data.test_id = http_resp.headers['x-amz-test-id']
        map = Hearth::JSON.parse(http_resp.body.read)
        data.test_config = (Parsers::TestConfig.parse(map['test_config']) unless map['test_config'].nil?)
        data
      end
    end

    class TestConfig
      def self.parse(map)
        data = Types::TestConfig.new
        data.timeout = map['timeout']
        return data
      end
    end

    class TestNoPayload
      def self.parse(http_resp)
        data = Types::TestNoPayloadOutput.new
        data.test_id = http_resp.headers['X-Amz-Test-Id']
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class TestPayloadBlob
      def self.parse(http_resp)
        data = Types::TestPayloadBlobOutput.new
        data.content_type = http_resp.headers['Content-Type']
        payload = http_resp.body.read
        data.data = payload unless payload.empty?
        data
      end
    end

    class TestPayloadStructure
      def self.parse(http_resp)
        data = Types::TestPayloadStructureOutput.new
        data.test_id = http_resp.headers['x-amz-test-id']
        json = Hearth::JSON.parse(http_resp.body.read)
        data.payload_config = Parsers::PayloadConfig.parse(json)
        data
      end
    end

    class TimestampFormatHeaders
      def self.parse(http_resp)
        data = Types::TimestampFormatHeadersOutput.new
        data.member_epoch_seconds = Time.at(http_resp.headers['X-memberEpochSeconds'].to_i) if http_resp.headers['X-memberEpochSeconds']
        data.member_http_date = Time.parse(http_resp.headers['X-memberHttpDate']) if http_resp.headers['X-memberHttpDate']
        data.member_date_time = Time.parse(http_resp.headers['X-memberDateTime']) if http_resp.headers['X-memberDateTime']
        data.default_format = Time.parse(http_resp.headers['X-defaultFormat']) if http_resp.headers['X-defaultFormat']
        data.target_epoch_seconds = Time.at(http_resp.headers['X-targetEpochSeconds'].to_i) if http_resp.headers['X-targetEpochSeconds']
        data.target_http_date = Time.parse(http_resp.headers['X-targetHttpDate']) if http_resp.headers['X-targetHttpDate']
        data.target_date_time = Time.parse(http_resp.headers['X-targetDateTime']) if http_resp.headers['X-targetDateTime']
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end

    class TimestampList
      def self.parse(list)
        list.map do |value|
          Time.parse(value) if value
        end
      end
    end

    class UnionPayload
      def self.parse(map)
        key, value = map.flatten
        case key
        when 'greeting'
          value = value
          Types::UnionPayload::Greeting.new(value) if value
        else
          Types::UnionPayload::Unknown.new(name: key, value: value)
        end
      end
    end

    class UnionWithJsonName
      def self.parse(map)
        key, value = map.flatten
        case key
        when 'FOO'
          value = value
          Types::UnionWithJsonName::Foo.new(value) if value
        when 'bar'
          value = value
          Types::UnionWithJsonName::Bar.new(value) if value
        when '_baz'
          value = value
          Types::UnionWithJsonName::Baz.new(value) if value
        else
          Types::UnionWithJsonName::Unknown.new(name: key, value: value)
        end
      end
    end

    class Unit
      def self.parse(map)
        data = Types::Unit.new
        return data
      end
    end

    class UnitInputAndOutput
      def self.parse(http_resp)
        data = Types::UnitInputAndOutputOutput.new
        map = Hearth::JSON.parse(http_resp.body.read)
        data
      end
    end
  end
end
