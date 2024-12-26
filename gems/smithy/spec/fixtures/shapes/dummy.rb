# frozen_string_literal: true

# This is generated code!

module ShapeService
  module Shapes
    include Smithy::Client::Shapes

    ReadOperationInput = StructureShape.new(id: "smithy.ruby.tests#ReadOperationInput", type: Types::ReadOperationInput, traits: {"smithy.api#input"=>{}})
    ReadOperationOutput = StructureShape.new(id: "smithy.ruby.tests#ReadOperationOutput", type: Types::ReadOperationOutput, traits: {"smithy.api#output"=>{}})
    SomeEnum = EnumShape.new(id: "smithy.ruby.tests#SomeEnum")
    SomeError = StructureShape.new(id: "smithy.ruby.tests#SomeError", type: Types::SomeError, traits: {"smithy.api#error"=>"client"})
    SomeId = StringShape.new(id: "smithy.ruby.tests#SomeId", traits: {"smithy.api#pattern"=>"^[A-Za-z0-9 ]+$"})
    SomeIntEnum = IntEnumShape.new(id: "smithy.ruby.tests#SomeIntEnum")
    SomeList = ListShape.new(id: "smithy.ruby.tests#SomeList")
    SomeMap = MapShape.new(id: "smithy.ruby.tests#SomeMap")
    SomeOperationInput = StructureShape.new(id: "smithy.ruby.tests#SomeOperationInput", type: Types::SomeOperationInput, traits: {"smithy.api#input"=>{}})
    SomeOperationOutput = StructureShape.new(id: "smithy.ruby.tests#SomeOperationOutput", type: Types::SomeOperationOutput, traits: {"smithy.api#output"=>{}})
    SomeProperties = StructureShape.new(id: "smithy.ruby.tests#SomeProperties", type: Types::SomeProperties)
    SomeUnion = StructureShape.new(id: "smithy.ruby.tests#SomeUnion", type: Types::SomeUnion)

    ReadOperationInput.add_member("some_id", SomeId, traits: {"smithy.api#required"=>{}})
    ReadOperationOutput.add_member("name", PreludeString, traits: {"smithy.api#notProperty"=>{}, "smithy.api#required"=>{}})
    ReadOperationOutput.add_member("some_properties", SomeProperties, traits: {"smithy.api#required"=>{}})
    SomeEnum.add_member("dog", PreludeUnit, traits: {"smithy.api#enumValue"=>"dog"})
    SomeEnum.add_member("cat", PreludeUnit, traits: {"smithy.api#enumValue"=>"cat"})
    SomeError.add_member("message", PreludeString, traits: {"smithy.api#required"=>{}})
    SomeIntEnum.add_member("foo", PreludeUnit, traits: {"smithy.api#enumValue"=>1})
    SomeIntEnum.add_member("bar", PreludeUnit, traits: {"smithy.api#enumValue"=>2})
    SomeList.set_member(PreludeString)
    SomeMap.set_member_key(PreludeString)
    SomeMap.set_member_value(PreludeInteger)
    SomeOperationInput.add_member("big_decimal", PreludeBigDecimal)
    SomeOperationInput.add_member("big_integer", PreludeBigInteger)
    SomeOperationInput.add_member("blob", PreludeBlob)
    SomeOperationInput.add_member("boolean", PreludeBoolean)
    SomeOperationInput.add_member("byte", PreludeByte)
    SomeOperationInput.add_member("double", PreludeDouble)
    SomeOperationInput.add_member("enum", SomeEnum)
    SomeOperationInput.add_member("float", PreludeFloat)
    SomeOperationInput.add_member("integer", PreludeInteger)
    SomeOperationInput.add_member("int_enum", SomeIntEnum)
    SomeOperationInput.add_member("long", PreludeLong)
    SomeOperationInput.add_member("short", PreludeShort)
    SomeOperationInput.add_member("string", PreludeString, traits: {"smithy.api#required"=>{}})
    SomeOperationInput.add_member("timestamp", PreludeTimestamp)
    SomeOperationOutput.add_member("list", SomeList)
    SomeOperationOutput.add_member("map", SomeMap)
    SomeOperationOutput.add_member("union", SomeUnion)
    SomeProperties.add_member("property_number", PreludeInteger, traits: {"smithy.api#required"=>{}})
    SomeUnion.add_member("thing", PreludeString)

    SCHEMA = Smithy::Client::Schema.new do |schema|
      schema.service = ServiceShape.new(
        id: "smithy.ruby.tests#ShapeService",
        version: "2018-10-31",
        traits: {"smithy.api#paginated"=>{"inputToken"=>"nextToken", "outputToken"=>"nextToken", "pageSize"=>"pageSize"}}
      )

      schema.add_operation(:read_operation, OperationShape.new do |operation|
        operation.id = "smithy.ruby.tests#ReadOperation"
        operation.input = ReadOperationInput
        operation.output = ReadOperationOutput
        operation.traits = {"smithy.api#readonly"=>{}}
        operation.errors << SomeError
      end)

      schema.add_operation(:some_operation, OperationShape.new do |operation|
        operation.id = "smithy.ruby.tests#SomeOperation"
        operation.input = SomeOperationInput
        operation.output = SomeOperationOutput

        operation.errors << SomeError
      end)

    end
  end
end
