# frozen_string_literal: true

require_relative 'smithy-model/schema'
require_relative 'smithy-model/shapes'
require_relative 'smithy-model/structure'
require_relative 'smithy-model/union'

module Smithy
  # Base module for Smithy model classes.
  module Model
    VERSION = File.read(File.expand_path('../VERSION', __dir__.to_s)).strip
  end
end
