# frozen_string_literal: true

require 'rails/railtie'
require 'smithy-client'
require 'thor'

require_relative 'smithy/command'
require_relative 'smithy/generators'
require_relative 'smithy/model'
require_relative 'smithy/plan'
require_relative 'smithy/util'
require_relative 'smithy/views'
require_relative 'smithy/weld'
require_relative 'smithy/welds'

require 'smithy/model2'

# Smithy is a modeling language created by AWS. This gem provides a Ruby
# implementation of the Smithy language and generates clients, servers, and schemas.
module Smithy
  VERSION = File.read(File.expand_path('../VERSION', __dir__.to_s)).strip

  # Generates Ruby code from a Smithy model and writes them to files.
  # @param [Plan] plan The plan to generate the artifacts from.
  # @return [Array<String>] The generated files.
  def self.generate(plan)
    plan.welds.each { |weld| weld.pre_process(plan.model) }
    artifacts = Smithy::Generators.generate(plan)
    plan.welds.each { |weld| weld.post_process(artifacts) }
    artifacts
  end

  # Generates minimal Ruby code from a Smithy model and returns the source code.
  # @param [Plan] plan The plan to generate the source from.
  # @return [String] The generated source code.
  def self.source(plan)
    plan.welds.each { |weld| weld.pre_process(plan.model) }
    Smithy::Generators.source(plan)
  end
end
