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

      Welds.load!(self)
      Polishes.load!(self)
      @welds = Welds.for(model)
      @polishes = Polishes.for(model)
    end

    # @return [Hash] The API model as a JSON hash.
    attr_reader :model

    # @return [Symbol] The type of code to generate.
    attr_reader :type

    # @return [Hash] The options passed to the generator.
    attr_reader :options

    # @return [Array<Weld>] The welds that apply to this plan.
    attr_reader :welds

    # @return [Array<Polish>] The polishes that apply to this plan.
    attr_reader :polishes
  end
end
