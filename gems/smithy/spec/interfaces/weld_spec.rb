# frozen_string_literal: true

describe 'Types: Welding' do
  Class.new(Smithy::Weld) do
    def preprocess(model)
      inspect = []
      inspect << model.inspect
      model['shapes']['example.weather#Weld'] = { 'type' => 'structure', 'members' => {} }
      puts '----------'
      inspect << model.inspect
      raise StandardError, inspect
    end
  end

  Class.new(Smithy::Weld) do
    def for?(_model)
      false
    end

    def preprocess(model)
      model['shapes']['example.weather#ShouldNotExist'] = { 'type' => 'structure', 'members' => {} }
    end
  end

  before(:all) do
    @tmpdir = SpecHelper.generate(['Weather'], :types)
  end

  after(:all) do
    SpecHelper.cleanup(['Weather'], @tmpdir)
  end

  it 'can preprocess the model' do
    weld = Weather::Types::Weld.new
    expect(weld).to be_a(Struct)
    expect(weld.members).to be_empty
  end

  it 'does not apply welds that return false for for?' do
    expect(defined?(Weather::Types::ShouldNotExist)).to be nil
  end
end
