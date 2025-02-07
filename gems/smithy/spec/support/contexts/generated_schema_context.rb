# frozen_string_literal: true

RSpec.shared_context 'generated schema gem' do |options|
  before(:all) do
    @plan = SpecHelper.generate_gem(:schema, options)
  end

  after(:all) do
    SpecHelper.cleanup_gem(@plan)
  end
end

RSpec.shared_context 'generated schema from source code' do |options|
  before(:all) do
    @module_name = SpecHelper.generate_from_source_code(:schema, options)
  end

  after(:all) do
    SpecHelper.cleanup_modules(@module_name)
  end
end
