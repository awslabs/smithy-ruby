# frozen_string_literal: true

describe 'Schema: Shapes', rbs_test: true do
  ['generated schema gem', 'generated schema from source code'].each do |context|
    next if ENV['SMITHY_RUBY_RBS_TEST'] && context != 'generated schema gem'

    context context do
      include_examples 'shapes module', context
    end
  end
end
