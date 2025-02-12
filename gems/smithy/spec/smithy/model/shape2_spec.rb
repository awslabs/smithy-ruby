# frozen_string_literal: true

module Smithy
  describe Model2 do
    let(:fixture) do
      JSON.load_file(File.expand_path('../../fixtures/shapes2/model.json', __dir__.to_s))
    end

    it 'does a thing' do
      model = Model2.new(fixture)
      require 'byebug'
      byebug
    end
  end
end
