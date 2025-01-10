# frozen_string_literal: true

module Smithy
  # The Plan class is a simple data structure that holds the model, type, and options for a generator.
  class Plan
    # @param [Hash] model The API model as a JSON hash.
    # @param [Symbol] type The type of code to generate, either :client, :server, or :types.
    # @param [Hash] options The options passed to the generator.
    def initialize(model, type, options = {})
      @model = model
      @type = type
      @options = options
      @service = find_service(model['shapes'])

      Rivets.load!(self)
      @rivets = Rivets.for(@service)
    end

    # @return [Hash] The API model as a JSON hash.
    attr_reader :model

    # @return [Symbol] The type of code to generate.
    attr_reader :type

    # @return [Hash] The options passed to the generator.
    attr_reader :options

    # @return [Array<Rivet>] The rivets that apply to this plan.
    attr_reader :rivets

    # @return [Hash<String, Hash>] The service shape for the shapes.
    attr_reader :service

    private

    def find_service(shapes)
      service = shapes.select { |_, shape| shape['type'] == 'service' }
      raise 'Multiple service shapes found' if service.size > 1
      raise 'No service shape found' if service.empty?

      service
    end
  end
end
