# frozen_string_literal: true

module Smithy
  # Base class that all welds must inherit from. Includes hooks for code generation.
  class Weld
    include Thor::Base
    include Thor::Actions

    # @param [Plan] plan The plan that is being executed.
    def initialize(plan)
      @plan = plan
      # Necessary for Thor::Base and Thor::Actions
      self.options = { force: true, quiet: plan.quiet }
      self.destination_root = plan.destination_root
      shell.base = self
    end

    # Called to determine if the weld should be applied for this model.
    # @param [Hash] service Service shape
    # @return [Boolean] (true) True if the weld should be applied, false otherwise.
    def for?(service) # rubocop:disable Lint/UnusedMethodArgument
      true
    end

    # Pre-process the model. Called before the model is loaded.
    # @param [Hash] model
    def pre_process(model)
      model
    end

    # Post-process the artifacts after they are generated.
    # @param [Array<String>] artifacts The files that were generated.
    def post_process(artifacts)
      artifacts
    end

    # Called when constructing endpoint parameters. Any bindings defined here will
    # be merged with other built-in bindings.
    # @return [Hash<String, Hash>] endpoint built in bindings for use in endpoint rules.
    def endpoint_built_in_bindings
      {}
    end

    # Called when constructing the endpoint provider. Any bindings defined here will
    # be merged with other function bindings.
    # @return [Hash<String, String>] endpoint function bindings for use in endpoint rules.
    def endpoint_function_bindings
      {}
    end

    # Called when constructing the client. Any plugins defined here will be merged
    # with other plugins.
    # @return [Hash<String, String>] a mapping of fully qualified class names as the
    #  key, and the plugin's file location as the value.
    # def plugins
    #   {}
    # end
  end
end
