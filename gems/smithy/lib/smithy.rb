# frozen_string_literal: true

require 'rails/railtie'
require 'thor'

require_relative 'smithy/command'
require_relative 'smithy/forge'
require_relative 'smithy/model'
require_relative 'smithy/plan'
require_relative 'smithy/rivet'
require_relative 'smithy/rivets'
require_relative 'smithy/util'
require_relative 'smithy/views'

# Smithy is a modeling language created by AWS. This gem provides a Ruby
# implementation of the Smithy language and generates clients, servers, and types.
module Smithy
  VERSION = File.read(File.expand_path('../VERSION', __dir__)).strip

  class << self
    # Generates a Ruby artifact from a Smithy model.
    # @param [Plan] plan The plan to generate the artifact from.
    def smith(plan)
      plan.rivets.each { |rivet| rivet.pre_process(plan.model) }
      artifacts = Smithy::Forge.forge(plan)
      plan.rivets.each { |rivet| rivet.post_process(artifacts) }
      artifacts
    end
  end
end
