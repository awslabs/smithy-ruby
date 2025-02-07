# frozen_string_literal: true

RSpec.shared_context 'generated client gem' do |options|
  before(:all) do
    @plan = SpecHelper.generate_client_gem(options)
  end

  after(:all) do
    SpecHelper.cleanup_client_gem(@plan)
  end
end

RSpec.shared_context 'generated client from source' do |options|
  before(:all) do
    @module_name = SpecHelper.generate_client_from_source(options)
  end

  after(:all) do
    SpecHelper.cleanup_client_source(@module_name)
  end
end
