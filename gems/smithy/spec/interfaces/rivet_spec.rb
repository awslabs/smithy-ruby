# frozen_string_literal: true

describe 'Integration: Rivets' do
  # rubocop:disable Lint/UselessAssignment
  before(:all) do
    # Define Rivet classes (scoped to this block only)
    used = Class.new(Smithy::Rivet) do
      def pre_process(model)
        model['shapes']['example.weather#Rivet'] = { 'type' => 'structure', 'members' => {} }
        model['shapes']['example.weather#GetForecastOutput']['members']['chanceOfRivets'] =
          { 'target' => 'example.weather#Rivet' }
      end

      def post_process(artifacts)
        file, _content = artifacts.find { |file, _content| file.include?('/types.rb') }
        inject_into_module(file, 'Types') do
          "    OtherRivet = Struct.new(keyword_init: true)\n"
        end
      end
    end

    unused = Class.new(Smithy::Rivet) do
      def for?(_model)
        false
      end

      def pre_process(model)
        model['shapes']['example.weather#RivetShouldNotExist'] = { 'type' => 'structure', 'members' => {} }
        model['shapes']['example.weather#GetForecastOutput']['members']['chanceOfRivets'] =
          { 'target' => 'example.weather#RivetShouldNotExist' }
      end

      def post_process(artifacts)
        file, _content = artifact.find { |file, _content| file.include?('/types.rb') }
        inject_into_module(file, 'Types') do
          "    OtherRivetShouldNotExist = Struct.new(keyword_init: true)\n"
        end
      end
    end

    @tmpdir = SpecHelper.generate(['Weather'], :types)
  end
  # rubocop:enable Lint/UselessAssignment

  after(:all) do
    SpecHelper.cleanup(['Weather'], @tmpdir)
  end

  it 'includes Thor::Actions' do
    expect(Class.new(Smithy::Rivet).ancestors).to include(Thor::Actions)
  end

  it 'can pre process the model' do
    rivet = Weather::Types::Rivet.new
    expect(rivet).to be_a(Struct)
    expect(rivet.members).to be_empty
    get_forecast_output = Weather::Types::GetForecastOutput.new
    expect(get_forecast_output.members).to include(:chance_of_rivets)
  end

  it 'can post process files' do
    other_rivet = Weather::Types::OtherRivet.new
    expect(other_rivet).to be_a(Struct)
  end

  it 'does not apply rivets that return false in #for?' do
    expect(defined?(Weather::Types::RivetShouldNotExist)).to be nil
    expect(defined?(Weather::Types::OtherRivetShouldNotExist)).to be nil
  end
end
