# frozen_string_literal: true

# This is generated code!

module Weather
  # TODO!
  class Client < Smithy::Client::Base
    self.schema = Shapes::SCHEMA

    add_plugin(Smithy::Client::Plugins::NetHTTP)
    add_plugin(Plugins::Endpoint)

    # TODO!
    def initialize(*args)
      super
    end

    # @example Request syntax with placeholder values
    #
    #   params = {
    #     city_id: "CityId", # required
    #   }
    #   options = {}
    #   output = client.get_city(params, options)
    #
    # @example Response structure with placeholder values
    #
    #   output.to_h #=>
    #   {
    #     name: "String", # required
    #     coordinates: { # required
    #       latitude: 1.0, # required
    #       longitude: 1.0, # required
    #     }
    #   }
    #
    def get_city(params = {}, options = {})
      input = build_input(:get_city, params)
      input.send_request(options)
    end

    # @example Request syntax with placeholder values
    #
    #   params = {}
    #   options = {}
    #   output = client.get_current_time(params, options)
    #
    # @example Response structure with placeholder values
    #
    #   output.to_h #=>
    #   {
    #     time: Time.now, # required
    #   }
    #
    def get_current_time(params = {}, options = {})
      input = build_input(:get_current_time, params)
      input.send_request(options)
    end

    # @example Request syntax with placeholder values
    #
    #   params = {
    #     city_id: "CityId", # required
    #   }
    #   options = {}
    #   output = client.get_forecast(params, options)
    #
    # @example Response structure with placeholder values
    #
    #   output.to_h #=>
    #   {
    #     chance_of_rain: 1.0
    #   }
    #
    def get_forecast(params = {}, options = {})
      input = build_input(:get_forecast, params)
      input.send_request(options)
    end

    # @example Request syntax with placeholder values
    #
    #   params = {
    #     next_token: "String",
    #     page_size: 1
    #   }
    #   options = {}
    #   output = client.list_cities(params, options)
    #
    # @example Response structure with placeholder values
    #
    #   output.to_h #=>
    #   {
    #     next_token: "String",
    #     items: [ # required
    #       {
    #         city_id: "CityId", # required
    #         name: "String", # required
    #       }
    #     ]
    #   }
    #
    def list_cities(params = {}, options = {})
      input = build_input(:list_cities, params)
      input.send_request(options)
    end

    private

    def build_input(operation_name, params)
      handlers = @handlers.for(operation_name)
      context = Smithy::Client::HandlerContext.new(
        operation_name: operation_name,
        operation: config.schema.operation(operation_name),
        client: self,
        params: params,
        config: config
      )
      context[:gem_name] = 'weather'
      context[:gem_version] = '1.0.0'
      Smithy::Client::Input.new(handlers: handlers, context: context)
    end
  end
end
