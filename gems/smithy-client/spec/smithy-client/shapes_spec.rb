# frozen_string_literal: true

module Smithy
  module Client
    module Shapes
      describe Shape do
        subject { Shape.new }

        describe '#initialize' do
          it 'defaults id to nil' do
            expect(subject.id).to be_nil
          end

          it 'defaults traits to empty hash' do
            expect(subject.traits).to eq({})
          end

          it 'can set id' do
            subject = Shape.new(id: 'foo')
            expect(subject.id).to eq('foo')
          end

          it 'can set traits' do
            subject = Shape.new(traits: { 'trait' => 'value' })
            expect(subject.traits).to eq({ 'trait' => 'value' })
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

      describe BigDecimalShape do
        subject { BigDecimalShape.new }

        it 'is a subclass of Shape' do
          expect(subject).to be_kind_of(Shape)
        end
      end

      describe BlobShape do
        subject { BlobShape.new }

        it 'is a subclass of Shape' do
          expect(subject).to be_kind_of(Shape)
        end
      end

      describe BooleanShape do
        subject { BooleanShape.new }

        it 'is a subclass of Shape' do
          expect(subject).to be_kind_of(Shape)
        end
      end

      describe DocumentShape do
        subject { DocumentShape.new }

        it 'is a subclass of Shape' do
          expect(subject).to be_kind_of(Shape)
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
            subject.add_member(:foo, StringShape.new)
            expect(subject.members[:foo]).to be_kind_of(MemberShape)
          end

          it 'can set traits on the member' do
            subject.add_member(:foo, StringShape.new, traits: { 'trait' => 'value' })
            expect(subject.members[:foo].traits).to eq({ 'trait' => 'value' })
          end
        end

        describe '#member?' do
          it 'returns true if member exists' do
            subject.add_member(:foo, StringShape.new)
            expect(subject.member?(:foo)).to be(true)
          end
        end

        describe '#member' do
          it 'returns the member' do
            subject.add_member(:foo, StringShape.new)
            expect(subject.member(:foo)).to be_kind_of(MemberShape)
          end
        end
      end

      describe IntegerShape do
        subject { IntegerShape.new }

        it 'is a subclass of Shape' do
          expect(subject).to be_kind_of(Shape)
        end
      end

      describe IntEnumShape do
        subject { IntEnumShape.new }

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
            subject.add_member(:foo, StringShape.new)
            expect(subject.members[:foo]).to be_kind_of(MemberShape)
          end

          it 'can set traits on the member' do
            subject.add_member(:foo, StringShape.new, traits: { 'trait' => 'value' })
            expect(subject.members[:foo].traits).to eq({ 'trait' => 'value' })
          end
        end

        describe '#member?' do
          it 'returns true if member exists' do
            subject.add_member(:foo, StringShape.new)
            expect(subject.member?(:foo)).to be(true)
          end
        end

        describe '#member' do
          it 'returns the member' do
            subject.add_member(:foo, StringShape.new)
            expect(subject.member(:foo)).to be_kind_of(MemberShape)
          end
        end
      end

      describe FloatShape do
        subject { FloatShape.new }

        it 'is a subclass of Shape' do
          expect(subject).to be_kind_of(Shape)
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
            subject.set_member(StringShape.new)
            expect(subject.member).to be_kind_of(MemberShape)
          end

          it 'can set traits on the member' do
            subject.set_member(StringShape.new, traits: { 'trait' => 'value' })
            expect(subject.member.traits).to eq({ 'trait' => 'value' })
          end
        end
      end

      describe MapShape do
        subject { MapShape.new }

        it 'is a subclass of Shape' do
          expect(subject).to be_kind_of(Shape)
        end

        describe '#initialize' do
          it 'key defaults to nil' do
            expect(subject.key).to be(nil)
          end

          it 'value defaults to nil' do
            expect(subject.value).to be(nil)
          end
        end

        describe '#set_key' do
          it 'sets a key' do
            subject.set_key(StringShape.new)
            expect(subject.key).to be_kind_of(MemberShape)
          end

          it 'can set traits on the key' do
            subject.set_key(StringShape.new, traits: { 'trait' => 'value' })
            expect(subject.key.traits).to eq({ 'trait' => 'value' })
          end
        end

        describe '#set_value' do
          it 'sets a value' do
            subject.set_value(StringShape.new)
            expect(subject.value).to be_kind_of(MemberShape)
          end

          it 'can set traits on the value' do
            subject.set_value(StringShape.new, traits: { 'trait' => 'value' })
            expect(subject.value.traits).to eq({ 'trait' => 'value' })
          end
        end
      end

      describe StringShape do
        subject { StringShape.new }

        it 'is a subclass of Shape' do
          expect(subject).to be_kind_of(Shape)
        end
      end

      describe StructureShape do
        subject { StructureShape.new }

        it 'is a subclass of Shape' do
          expect(subject).to be_kind_of(Shape)
        end

        describe '#initialize' do
          it 'defaults members to empty hash' do
            expect(subject.members).to be_empty
          end

          it 'defaults type to nil' do
            expect(subject.type).to be(nil)
          end
        end

        describe '#add_member' do
          it 'adds a member' do
            subject.add_member(:foo, StringShape.new)
            expect(subject.members[:foo]).to be_kind_of(MemberShape)
          end

          it 'can set traits on the member' do
            subject.add_member(:foo, StringShape.new, traits: { 'trait' => 'value' })
            expect(subject.members[:foo].traits).to eq({ 'trait' => 'value' })
          end
        end

        describe '#member?' do
          it 'returns true if member exists' do
            subject.add_member(:foo, StringShape.new)
            expect(subject.member?(:foo)).to be(true)
          end
        end

        describe '#member' do
          it 'returns the member' do
            subject.add_member(:foo, StringShape.new)
            expect(subject.member(:foo)).to be_kind_of(MemberShape)
          end
        end
      end

      describe TimestampShape do
        subject { TimestampShape.new }

        it 'is a subclass of Shape' do
          expect(subject).to be_kind_of(Shape)
        end
      end

      describe MemberShape do
        subject { MemberShape.new(Shape.new) }

        describe '#initialize' do
          it 'sets the shape' do
            expect(subject.shape).to be_kind_of(Shape)
          end

          it 'can set traits' do
            subject = MemberShape.new(Shape.new, traits: { 'trait' => 'value' })
            expect(subject.traits).to eq({ 'trait' => 'value' })
          end
        end
      end

      describe UnionShape do
        subject { UnionShape.new }

        it 'is a subclass of Shape' do
          expect(subject).to be_kind_of(Shape)
        end

        describe '#initialize' do
          it 'defaults members to empty hash' do
            expect(subject.members).to be_empty
          end

          it 'defaults member_types to empty hash' do
            expect(subject.member_types).to be_empty
          end
        end

        describe '#add_member' do
          let(:member_type) { Class.new }

          it 'adds a member with its type' do
            subject.add_member(:foo, StringShape.new, member_type)
            expect(subject.members[:foo]).to be_kind_of(MemberShape)
            expect(subject.member_types[:foo]).to be(member_type)
          end
        end

        describe '#member?' do
          it 'returns true if member exists' do
            subject.add_member(:foo, StringShape.new, Class.new)
            expect(subject.member?(:foo)).to be(true)
          end
        end

        describe '#member' do
          it 'returns the member' do
            subject.add_member(:foo, StringShape.new, Class.new)
            expect(subject.member(:foo)).to be_kind_of(MemberShape)
          end
        end

        describe '#member_type' do
          it 'returns the member type' do
            member_type = Class.new
            subject.add_member(:foo, StringShape.new, member_type)
            expect(subject.member_type(:foo)).to be(member_type)
          end
        end
      end

      describe Prelude do
        it 'is a module' do
          expect(Prelude).to be_kind_of(Module)
        end

        it 'has prelude shapes' do
          expect(Prelude::BigDecimal).to be_kind_of(BigDecimalShape)
          expect(Prelude::BigInteger).to be_kind_of(IntegerShape)
          expect(Prelude::Blob).to be_kind_of(BlobShape)
          expect(Prelude::Boolean).to be_kind_of(BooleanShape)
          expect(Prelude::Byte).to be_kind_of(IntegerShape)
          expect(Prelude::Document).to be_kind_of(DocumentShape)
          expect(Prelude::Double).to be_kind_of(FloatShape)
          expect(Prelude::Float).to be_kind_of(FloatShape)
          expect(Prelude::Integer).to be_kind_of(IntegerShape)
          expect(Prelude::Long).to be_kind_of(IntegerShape)
          expect(Prelude::PrimitiveBoolean).to be_kind_of(BooleanShape)
          expect(Prelude::PrimitiveByte).to be_kind_of(IntegerShape)
          expect(Prelude::PrimitiveDouble).to be_kind_of(FloatShape)
          expect(Prelude::PrimitiveFloat).to be_kind_of(FloatShape)
          expect(Prelude::PrimitiveInteger).to be_kind_of(IntegerShape)
          expect(Prelude::PrimitiveShort).to be_kind_of(IntegerShape)
          expect(Prelude::PrimitiveLong).to be_kind_of(IntegerShape)
          expect(Prelude::Short).to be_kind_of(IntegerShape)
          expect(Prelude::String).to be_kind_of(StringShape)
          expect(Prelude::Timestamp).to be_kind_of(TimestampShape)
          expect(Prelude::Unit).to be_kind_of(StructureShape)
        end
      end
    end
  end
end
