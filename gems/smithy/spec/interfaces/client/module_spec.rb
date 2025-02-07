# frozen_string_literal: true

describe 'Client: Module' do
  context 'single module' do
    ['generated client gem', 'generated client from source code'].each do |context|
      context context do
        include_examples 'gem module', context
      end
    end
  end
end
