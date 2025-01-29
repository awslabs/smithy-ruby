# frozen_string_literal: true

module Smithy
  # The Plan class is a simple data structure that holds the model, type, and options for a generator.
  class Plan
    # @param [Hash] model The API model as a JSON hash.
    # @param [Symbol] type The type of code to generate, either :client, :server, or :schema.
    # @param [Hash] options The options passed to the generator.
    def initialize(model, type, options = {})
      @model = model
      @type = type
      @options = options
      @service = find_service(model['shapes'])

      Welds.load!(self)
      @welds = Welds.for(@service)
    end

    # @return [Hash] The API model as a JSON hash.
    attr_reader :model

    # @return [Symbol] The type of code to generate.
    attr_reader :type

    # @return [Hash] The options passed to the generator.
    attr_reader :options

    # @return [Array<Weld>] The welds that apply to this plan.
    attr_reader :welds

    # @return [Hash<String, Hash>] The service shape for the shapes.
    attr_reader :service

    # @return [String] The full namespace for the gem.
    def gem_namespace
      @options[:gem_namespace] || Util::Namespace.namespace_from_gem_name(@options[:gem_name])
    end

    private

    def find_service(shapes)
      service = shapes.select { |_, shape| shape['type'] == 'service' }
      raise 'Multiple service shapes found' if service.size > 1
      raise 'No service shape found' if service.empty?

      service
    end
  end
end
