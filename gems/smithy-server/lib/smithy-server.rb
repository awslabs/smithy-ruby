# frozen_string_literal: true

module Smithy
  module Server
    VERSION = File.read(File.expand_path('../VERSION', __dir__.to_s)).strip
  end
end
