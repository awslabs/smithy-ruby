# frozen_string_literal: true

module Smithy
  module Client
    module Shapes
      describe Shape do
        subject { Shape.new }

        describe '#initialize' do
          it 'defaults id to nil' do
            expect(subject.id).to be(nil)
          end

          it 'defaults traits to an empty hash' do
            expect(subject.traits).to be_empty
          end
        end
      end

      describe ServiceShape do
        subject { ServiceShape.new }

        it 'is a subclass of Shape' do
          expect(subject).to be_kind_of(Shape)
        end

        describe '#initialize' do
          it 'defaults version to nil' do
            expect(subject.version).to be(nil)
          end

          it 'version can be read when set' do
            subject = ServiceShape.new(version: '2015-01-01')
            expect(subject.version).to eq('2015-01-01')
          end
        end
      end

      describe OperationShape do
        subject { OperationShape.new }

        it 'is a subclass of Shape' do
          expect(subject).to be_kind_of(Shape)
        end

        describe '#initialize' do
          let(:structure_shape) { StructureShape.new }

          context 'error attribute' do
            it 'defaults to empty array' do
              expect(subject.errors).to be_empty
            end

            it 'can be read when set' do
              subject = OperationShape.new(errors: [structure_shape])
              expect(subject.errors).to eq([structure_shape])
            end
          end

          context 'input attribute' do
            it 'defaults to nil' do
              expect(subject.input).to be(nil)
            end

            it 'can be read when set' do
              subject = OperationShape.new(input: structure_shape)
              expect(subject.input).to be(structure_shape)
            end
          end

          context 'output attribute' do
            it 'defaults to nil' do
              expect(subject.output).to be(nil)
            end

            it 'can be read when set' do
              subject = OperationShape.new(output: structure_shape)
              expect(subject.output).to be(structure_shape)
            end
          end
        end
      end

      describe EnumShape do
        subject { EnumShape.new }

        it 'is a subclass of Shape' do
          expect(subject).to be_kind_of(Shape)
        end

        describe '#initialize' do
          context 'members attribute' do
            it 'defaults to empty hash' do
              expect(subject.members).to be_empty
            end
          end
        end

        describe '#add_member' do
          it 'adds a member' do
            member_name = 'FOO'
            subject.add_member(member_name, StringShape.new)
            expect(subject.members[member_name])
              .to be_kind_of(MemberShape)
          end
        end
      end

      describe ListShape do
        subject { ListShape.new }

        it 'is a subclass of Shape' do
          expect(subject).to be_kind_of(Shape)
        end

        describe '#initialize' do
          context 'member attribute' do
            it 'defaults to nil' do
              expect(subject.member).to be(nil)
            end
          end
        end

        describe '#set_member' do
          it 'sets a member' do
            member_name = 'string_member'
            subject.set_member(member_name, StringShape.new)
            expect(subject.member.name).to eq(member_name)
            expect(subject.member).to be_kind_of(MemberShape)
          end
        end
      end

      describe MapShape do
        subject { MapShape.new }

        it 'is a subclass of Shape' do
          expect(subject).to be_kind_of(Shape)
        end

        describe '#initialize' do
          context 'member key attribute' do
            it 'defaults to nil' do
              expect(subject.member_key).to be(nil)
            end
          end

          context 'member value attribute' do
            it 'defaults to nil' do
              expect(subject.member_value).to be(nil)
            end
          end
        end

        describe '#set_member_key' do
          it 'sets a member key' do
            subject.set_member_key(StringShape.new)
            expect(subject.member_key.name).to eq('key')
            expect(subject.member_key).to be_kind_of(MemberShape)
          end
        end

        describe '#set_member_value' do
          it 'sets a member value' do
            subject.set_member_value(StringShape.new)
            expect(subject.member_value.name).to eq('value')
            expect(subject.member_value).to be_kind_of(MemberShape)
          end
        end
      end

      describe StructureShape do
        subject { StructureShape.new }

        it 'is a subclass of Shape' do
          expect(subject).to be_kind_of(Shape)
        end

        describe '#initialize' do
          context 'members attribute' do
            it 'defaults to empty hash' do
              expect(subject.members).to be_empty
            end
          end

          context 'type attribute' do
            it 'defaults to nil' do
              expect(subject.type).to be(nil)
            end
          end
        end

        describe '#add_member' do
          it 'adds a member' do
            member_name = 'string_member'
            subject.add_member(member_name, StringShape.new)
            expect(subject.members[member_name])
              .to be_kind_of(MemberShape)
          end
        end
      end
    end
  end
end
