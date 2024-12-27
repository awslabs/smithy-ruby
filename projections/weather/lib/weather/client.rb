# frozen_string_literal: true

# This is generated code!

module Weather
  class Client < Smithy::Client::Base
    # self.api = API

    add_plugin(Smithy::Client::Plugins::NetHTTP)


    # TODO
    def initialize(*args)
      super(*args)
    end

    # TODO!
    def get_city(params = {}, options = {})
      input = build_input(:get_city, params)
      input.send_request(options)
    end

    # TODO!
    def get_current_time(params = {}, options = {})
      input = build_input(:get_current_time, params)
      input.send_request(options)
    end

    # TODO!
    def get_forecast(params = {}, options = {})
      input = build_input(:get_forecast, params)
      input.send_request(options)
    end

    # TODO!
    def list_cities(params = {}, options = {})
      input = build_input(:list_cities, params)
      input.send_request(options)
    end

    private

    def build_input(operation_name, params)
      handlers = @handlers.for(operation_name)
      context = Smithy::Client::HandlerContext.new(
        operation_name: operation_name,
        operation: config.api.operation(operation_name),
        client: self,
        params: params,
        config: config
      )
      context[:gem_name] = 'weather'
      context[:gem_version] = '1.0.0'
      Smithy::Client::Input.new(handlers, context)
    end
  end
end
