# frozen_string_literal: true

# This is generated code!

module Weather
  module Types
    # TODO!
    CityCoordinates = Struct.new(
      :latitude,
      :longitude,
      keyword_init: true
    ) do
      include Smithy::Client::Structure
    end

    # TODO!
    CitySummary = Struct.new(
      :city_id,
      :name,
      keyword_init: true
    ) do
      include Smithy::Client::Structure
    end

    # TODO!
    GetCityInput = Struct.new(
      :city_id,
      keyword_init: true
    ) do
      include Smithy::Client::Structure
    end

    # TODO!
    GetCityOutput = Struct.new(
      :name,
      :coordinates,
      keyword_init: true
    ) do
      include Smithy::Client::Structure
    end

    # TODO!
    GetCurrentTimeOutput = Struct.new(
      :time,
      keyword_init: true
    ) do
      include Smithy::Client::Structure
    end

    # TODO!
    GetForecastInput = Struct.new(
      :city_id,
      keyword_init: true
    ) do
      include Smithy::Client::Structure
    end

    # TODO!
    GetForecastOutput = Struct.new(
      :chance_of_rain,
      keyword_init: true
    ) do
      include Smithy::Client::Structure
    end

    # TODO!
    ListCitiesInput = Struct.new(
      :next_token,
      :page_size,
      keyword_init: true
    ) do
      include Smithy::Client::Structure
    end

    # TODO!
    ListCitiesOutput = Struct.new(
      :next_token,
      :items,
      keyword_init: true
    ) do
      include Smithy::Client::Structure
    end

    # TODO!
    NoSuchResource = Struct.new(
      :resource_type,
      keyword_init: true
    ) do
      include Smithy::Client::Structure
    end
  end
end
