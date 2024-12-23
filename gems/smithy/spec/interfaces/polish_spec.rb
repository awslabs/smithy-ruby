# frozen_string_literal: true

describe 'Types: Polishing' do
  before(:all) do
    # Define Polish classes (scoped to this block only)
    Class.new(Smithy::Polish) do
      def polish(artifact)
        file, _content = artifact.find { |file, _content| file.include?('/types.rb') }
        inject_into_module(file, 'Types') do
          "    Polish = Struct.new(keyword_init: true)\n"
        end
      end
    end

    Class.new(Smithy::Polish) do
      def for?(_model)
        false
      end

      def polish(artifact)
        file, _content = artifact.find { |file, _content| file.include?('/types.rb') }
        inject_into_module(file, 'Types') do
          "    ShouldNotExist = Struct.new(keyword_init: true)\n"
        end
      end
    end
    @tmpdir = SpecHelper.generate(['Weather'], :types)
  end

  after(:all) do
    SpecHelper.cleanup(['Weather'], @tmpdir)
  end

  it 'includes Thor::Actions' do
    expect(Class.new(Smithy::Polish).ancestors).to include(Thor::Actions)
  end

  it 'can manipulate files' do
    polish = Weather::Types::Polish.new
    expect(polish).to be_a(Struct)
  end

  it 'does not apply polishes that return false for for?' do
    expect(defined?(Weather::Types::ShouldNotExist)).to be nil
  end
end
