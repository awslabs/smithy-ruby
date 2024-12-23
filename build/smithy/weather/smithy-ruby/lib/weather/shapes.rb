# frozen_string_literal: true

# This is generated code!

module Weather
  module Shapes
    include Smithy::Client::Shapes

    CityCoordinates = StructureShape.new(id: "example.weather#CityCoordinates", type: Types::CityCoordinates)
    CityId = StringShape.new(id: "example.weather#CityId", traits: {"smithy.api#pattern"=>"^[A-Za-z0-9 ]+$"})
    CitySummaries = ListShape.new(id: "example.weather#CitySummaries")
    CitySummary = StructureShape.new(id: "example.weather#CitySummary", type: Types::CitySummary, traits: {"smithy.api#references"=>[{"resource"=>"example.weather#City"}]})
    GetCityInput = StructureShape.new(id: "example.weather#GetCityInput", type: Types::GetCityInput, traits: {"smithy.api#input"=>{}})
    GetCityOutput = StructureShape.new(id: "example.weather#GetCityOutput", type: Types::GetCityOutput, traits: {"smithy.api#output"=>{}})
    GetCurrentTimeOutput = StructureShape.new(id: "example.weather#GetCurrentTimeOutput", type: Types::GetCurrentTimeOutput, traits: {"smithy.api#output"=>{}})
    GetForecastInput = StructureShape.new(id: "example.weather#GetForecastInput", type: Types::GetForecastInput, traits: {"smithy.api#input"=>{}})
    GetForecastOutput = StructureShape.new(id: "example.weather#GetForecastOutput", type: Types::GetForecastOutput, traits: {"smithy.api#output"=>{}})
    ListCitiesInput = StructureShape.new(id: "example.weather#ListCitiesInput", type: Types::ListCitiesInput, traits: {"smithy.api#input"=>{}})
    ListCitiesOutput = StructureShape.new(id: "example.weather#ListCitiesOutput", type: Types::ListCitiesOutput, traits: {"smithy.api#output"=>{}})
    NoSuchResource = StructureShape.new(id: "example.weather#NoSuchResource", type: Types::NoSuchResource, traits: {"smithy.api#error"=>"client"})

    CityCoordinates.add_member("latitude", PreludeFloat, traits: {"smithy.api#required"=>{}})
    CityCoordinates.add_member("longitude", PreludeFloat, traits: {"smithy.api#required"=>{}})
    CitySummary.add_member("city_id", CityId, traits: {"smithy.api#required"=>{}})
    CitySummary.add_member("name", PreludeString, traits: {"smithy.api#required"=>{}})
    GetCityInput.add_member("city_id", CityId, traits: {"smithy.api#required"=>{}})
    GetCityOutput.add_member("name", PreludeString, traits: {"smithy.api#notProperty"=>{}, "smithy.api#required"=>{}})
    GetCityOutput.add_member("coordinates", CityCoordinates, traits: {"smithy.api#required"=>{}})
    GetCurrentTimeOutput.add_member("time", PreludeTimestamp, traits: {"smithy.api#required"=>{}})
    GetForecastInput.add_member("city_id", CityId, traits: {"smithy.api#required"=>{}})
    GetForecastOutput.add_member("chance_of_rain", PreludeFloat)
    ListCitiesInput.add_member("next_token", PreludeString)
    ListCitiesInput.add_member("page_size", PreludeInteger)
    ListCitiesOutput.add_member("next_token", PreludeString)
    ListCitiesOutput.add_member("items", CitySummaries, traits: {"smithy.api#required"=>{}})
    NoSuchResource.add_member("resource_type", PreludeString, traits: {"smithy.api#required"=>{}})

    SCHEMA = Smithy::Client::Schema.new do |schema|
      schema.service = ServiceShape.new(
        id: "example.weather#Weather",
        version: "2006-03-01",
        traits: {"smithy.api#paginated"=>{"inputToken"=>"nextToken", "outputToken"=>"nextToken", "pageSize"=>"pageSize"}}
      )

      schema.add_operation(:get_city, OperationShape.new do |operation|
        operation.id = "example.weather#GetCity"
        operation.input = GetCityInput
        operation.output = GetCityOutput
        operation.traits = {"smithy.api#readonly"=>{}}              
        operation.errors << NoSuchResource             
      end)
    
      schema.add_operation(:get_current_time, OperationShape.new do |operation|
        operation.id = "example.weather#GetCurrentTime"
        operation.input = PreludeUnit
        operation.output = GetCurrentTimeOutput
        operation.traits = {"smithy.api#readonly"=>{}}       
      end)
    
      schema.add_operation(:get_forecast, OperationShape.new do |operation|
        operation.id = "example.weather#GetForecast"
        operation.input = GetForecastInput
        operation.output = GetForecastOutput
        operation.traits = {"smithy.api#readonly"=>{}}       
      end)
    
      schema.add_operation(:list_cities, OperationShape.new do |operation|
        operation.id = "example.weather#ListCities"
        operation.input = ListCitiesInput
        operation.output = ListCitiesOutput
        operation.traits = {"smithy.api#paginated"=>{"items"=>"items"}, "smithy.api#readonly"=>{}}       
      end)
    
    end
  end
end
