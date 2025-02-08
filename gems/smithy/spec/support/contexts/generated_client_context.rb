# frozen_string_literal: true

RSpec.shared_context 'generated client gem' do |module_name, options|
  before(:all) do
    @plan = SpecHelper.generate_gem(module_name, :client, **options)
  end

  after(:all) do
    SpecHelper.cleanup_gem(@plan)
  end
end

RSpec.shared_context 'generated client from source code' do |module_name, options|
  before(:all) do
    @module_name = SpecHelper.generate_from_source_code(module_name, :client, **options)
  end

  after(:all) do
    SpecHelper.cleanup_modules(@module_name)
  end
end
