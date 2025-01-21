# frozen_string_literal: true

# This is generated code!

module Weather
  # This module contains the shapes used by the client.
  module Shapes
    include Smithy::Client::Shapes

    CityCoordinates = StructureShape.new(id: 'example.weather#CityCoordinates', traits: {})
    CityId = StringShape.new(id: 'example.weather#CityId', traits: { 'smithy.api#pattern' => '^[A-Za-z0-9 ]+$' })
    CitySummaries = ListShape.new(id: 'example.weather#CitySummaries', traits: {})
    CitySummary = StructureShape.new(id: 'example.weather#CitySummary', traits: { 'smithy.api#references' => [{ 'resource' => 'example.weather#City' }] })
    GetCityInput = StructureShape.new(id: 'example.weather#GetCityInput', traits: { 'smithy.api#input' => {} })
    GetCityOutput = StructureShape.new(id: 'example.weather#GetCityOutput', traits: { 'smithy.api#output' => {} })
    GetCurrentTimeOutput = StructureShape.new(id: 'example.weather#GetCurrentTimeOutput', traits: { 'smithy.api#output' => {} })
    GetForecastInput = StructureShape.new(id: 'example.weather#GetForecastInput', traits: { 'smithy.api#input' => {} })
    GetForecastOutput = StructureShape.new(id: 'example.weather#GetForecastOutput', traits: { 'smithy.api#output' => {} })
    ListCitiesInput = StructureShape.new(id: 'example.weather#ListCitiesInput', traits: { 'smithy.api#input' => {} })
    ListCitiesOutput = StructureShape.new(id: 'example.weather#ListCitiesOutput', traits: { 'smithy.api#output' => {} })
    NoSuchResource = StructureShape.new(id: 'example.weather#NoSuchResource', traits: { 'smithy.api#error' => 'client' })

    CityCoordinates.add_member(:latitude, Prelude::Float, { 'smithy.api#required' => {} })
    CityCoordinates.add_member(:longitude, Prelude::Float, { 'smithy.api#required' => {} })
    CityCoordinates.type = Types::CityCoordinates

    CitySummaries.set_member(CitySummary, {})

    CitySummary.add_member(:city_id, CityId, { 'smithy.api#required' => {} })
    CitySummary.add_member(:name, Prelude::String, { 'smithy.api#required' => {} })
    CitySummary.type = Types::CitySummary

    GetCityInput.add_member(:city_id, CityId, { 'smithy.api#required' => {} })
    GetCityInput.type = Types::GetCityInput

    GetCityOutput.add_member(:name, Prelude::String, { 'smithy.api#notProperty' => {}, 'smithy.api#required' => {} })
    GetCityOutput.add_member(:coordinates, CityCoordinates, { 'smithy.api#required' => {} })
    GetCityOutput.type = Types::GetCityOutput

    GetCurrentTimeOutput.add_member(:time, Prelude::Timestamp, { 'smithy.api#required' => {} })
    GetCurrentTimeOutput.type = Types::GetCurrentTimeOutput

    GetForecastInput.add_member(:city_id, CityId, { 'smithy.api#required' => {} })
    GetForecastInput.type = Types::GetForecastInput

    GetForecastOutput.add_member(:chance_of_rain, Prelude::Float, {})
    GetForecastOutput.type = Types::GetForecastOutput

    ListCitiesInput.add_member(:next_token, Prelude::String, {})
    ListCitiesInput.add_member(:page_size, Prelude::Integer, {})
    ListCitiesInput.type = Types::ListCitiesInput

    ListCitiesOutput.add_member(:next_token, Prelude::String, {})
    ListCitiesOutput.add_member(:items, CitySummaries, { 'smithy.api#required' => {} })
    ListCitiesOutput.type = Types::ListCitiesOutput

    NoSuchResource.add_member(:resource_type, Prelude::String, { 'smithy.api#required' => {} })
    NoSuchResource.type = Types::NoSuchResource

    SCHEMA = Smithy::Client::Schema.new do |schema|
      schema.service = ServiceShape.new(
        id: 'example.weather#Weather',
        version: '2006-03-01',
        traits: { 'smithy.api#paginated' => { 'inputToken' => 'nextToken', 'outputToken' => 'nextToken', 'pageSize' => 'pageSize' } }
      )
      schema.add_operation(:get_city, OperationShape.new do |operation|
        operation.id = 'example.weather#GetCity'
        operation.input = GetCityInput
        operation.output = GetCityOutput
        operation.traits = { 'smithy.api#readonly' => {} }
        operation.errors << NoSuchResource
      end)
      schema.add_operation(:get_current_time, OperationShape.new do |operation|
        operation.id = 'example.weather#GetCurrentTime'
        operation.input = Prelude::Unit
        operation.output = GetCurrentTimeOutput
        operation.traits = { 'smithy.api#readonly' => {} }
      end)
      schema.add_operation(:get_forecast, OperationShape.new do |operation|
        operation.id = 'example.weather#GetForecast'
        operation.input = GetForecastInput
        operation.output = GetForecastOutput
        operation.traits = { 'smithy.api#readonly' => {} }
      end)
      schema.add_operation(:list_cities, OperationShape.new do |operation|
        operation.id = 'example.weather#ListCities'
        operation.input = ListCitiesInput
        operation.output = ListCitiesOutput
        operation.traits = { 'smithy.api#paginated' => { 'items' => 'items' }, 'smithy.api#readonly' => {} }
      end)
    end
  end
end
