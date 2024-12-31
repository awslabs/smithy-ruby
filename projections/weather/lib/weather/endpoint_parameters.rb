# frozen_string_literal: true

# This is generated code!

module Weather
  # Endpoint parameters used to influence endpoints per request.
  # TODO: Documentation
  EndpointParameters = Struct.new(
    :endpoint,
    keyword_init: true
  ) do
    include Smithy::Client::Structure

    def initialize(options = {})
      self[:endpoint] = options.fetch(:endpoint, nil)
    end

    def self.create(config, _operation_name = nil, _params = {})
      new({
        endpoint: config.endpoint
      }.compact)
    end
  end
end
