# frozen_string_literal: true

module Smithy
  # Base class that all welds must inherit from. Includes hooks for the forging process.
  class Weld
    # @param [Plan] plan The plan to weld with.
    def initialize(plan)
      @plan = plan
    end

    # Called to determine if the weld should be applied for this model.
    # @param [Hash] _model
    # @return [Boolean] (true) True if the weld should be applied, false otherwise.
    def for?(_model)
      true
    end

    # Preprocess the model. Called before the model is loaded.
    # @param [Hash] _model
    def preprocess(_model)
      # no-op
    end

    # Called when constructing a plan
    # @return [Hash<String, Hash>] endpoint built in bindings for use in endpoint rules.
    def endpoint_built_in_bindings
      {}
    end

    # Called when constructing a plan
    # @return [Hash<String, String>] endpoint function bindings for use in endpoint rules.
    def endpoint_function_bindings
      {}
    end
  end
end
