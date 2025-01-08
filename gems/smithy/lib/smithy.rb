# frozen_string_literal: true

require 'rails/railtie'
require 'thor'

require_relative 'smithy/anvil'
require_relative 'smithy/command'
require_relative 'smithy/forge'
require_relative 'smithy/model'
require_relative 'smithy/plan'
require_relative 'smithy/polish'
require_relative 'smithy/polishes'
require_relative 'smithy/util'
require_relative 'smithy/weld'
require_relative 'smithy/welds'

# Smithy is a modeling language created by AWS. This gem provides a Ruby
# implementation of the Smithy language and generates clients, servers, and types.
module Smithy
  VERSION = File.read(File.expand_path('../VERSION', __dir__)).strip

  class << self
    # Generates a Ruby artifact from a Smithy model.
    # @param [Plan] plan The plan to generate the artifact from.
    def smith(plan)
      plan.welds.each { |weld| weld.preprocess(plan.model) }
      artifact = Smithy::Forge.forge(plan)
      plan.polishes.each { |polish| polish.polish(artifact) }
      artifact
    end
  end
end
