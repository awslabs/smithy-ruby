# frozen_string_literal: true

describe 'Model: Mixins' do
  include_context 'generated client gem', 'Mixins'
  it 'merges traits with correct precedence' do
    expect(Mixins::Shapes::StructD.traits['smithy.ruby.tests#foo']).to be(2)
    # Order is important
    expect(Mixins::Shapes::StructD.traits.keys).to eq([
                                                        'smithy.ruby.tests#fourTrait',
                                                        'smithy.ruby.tests#threeTrait',
                                                        'smithy.ruby.tests#foo',
                                                        'smithy.ruby.tests#twoTrait',
                                                        'smithy.ruby.tests#oneTrait'
                                                      ])
  end

  it 'excludes localTraits' do
    expect(Mixins::Shapes::PublicShape.traits).not_to include('smithy.api#mixin', 'smithy.api#private')
  end

  it 'applies and overrides mixin traits' do
    expect(Mixins::Shapes::MyStruct.members[:mixin_member].traits['smithy.ruby.tests#tag']).to eq 'specific tag'
  end

  it 'merges with the correct member order' do
    expect(Mixins::Shapes::ListSomethingInput.members.keys)
      .to eq(%i[next_token page_size name_filter size_filter])
  end
end
