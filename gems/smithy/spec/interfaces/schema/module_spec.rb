# frozen_string_literal: true

describe 'Schema: Module' do
  context 'single module' do
    ['generated schema gem', 'generated schema from source code'].each do |context|
      context context do
        include_examples 'gem module', context
      end
    end
  end
end
