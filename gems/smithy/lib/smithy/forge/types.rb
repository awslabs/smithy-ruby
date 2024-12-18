# frozen_string_literal: true

module Smithy
  module Forge
    # Forges a gem for the types.
    class Types < Base
      # @param plan [Smithy::Plan] The plan to forge.
      # @return [void]
      def initialize(plan)
        @plan = plan
        @gem_name = "#{plan.options[:gem_name]}-types"
        super
      end

      private

      def source_files
        Enumerator.new do |e|
          e.yield "#{@gem_name}.gemspec", Anvil::Client::Views::Gemspec.new(@plan).hammer
          e.yield "lib/#{@gem_name}.rb", Anvil::Client::Views::Module.new(@plan).hammer
          e.yield "lib/#{@gem_name}/types.rb", Anvil::Client::Views::Types.new(@plan).hammer
        end
      end
    end
  end
end
