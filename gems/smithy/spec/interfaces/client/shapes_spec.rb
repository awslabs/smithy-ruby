# frozen_string_literal: true

describe 'Client: Shapes', rbs_test: true do
  ['generated client gem', 'generated client from source code'].each do |context|
    next if ENV['SMITHY_RUBY_RBS_TEST'] && context != 'generated client gem'

    context context do
      include_examples 'shapes module', context
    end
  end
end
