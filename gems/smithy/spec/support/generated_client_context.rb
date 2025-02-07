# frozen_string_literal: true

RSpec.shared_context 'generated client gem' do |options|
  before(:all) do
    @plan = SpecHelper.generate_gem(:client, options)
  end

  after(:all) do
    SpecHelper.cleanup_gem(@plan)
  end
end

RSpec.shared_context 'generated client from source code' do |options|
  before(:all) do
    @module_name = SpecHelper.generate_from_source_code(:client, options)
  end

  after(:all) do
    SpecHelper.cleanup_eval_source(@module_name)
  end
end
