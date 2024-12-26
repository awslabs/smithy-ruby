# frozen_string_literal: true

describe 'Component: Shapes' do
  shape_tests = JSON.load_file(
    File.expand_path('../../fixtures/shapes/shape_tests.json', __dir__)
  )

  before(:all) do
    @tmpdir = SpecHelper.generate(['ShapeService'], :client, fixture: 'shapes')
  end

  after(:all) do
    SpecHelper.cleanup(['ShapeService'], @tmpdir)
  end

  subject { ShapeService::Shapes }
  let(:service) { ShapeService }
  let(:types_module) { service::Types }
  let(:shapes_module) { Smithy::Client::Shapes }

  it 'generates a shapes module' do
    expect(subject).to be_a(Module)
  end

  context 'generated shapes' do
    shape_tests.each do |shape, test_case|
      context 'a given shape' do
        next if %w[OperationShape ServiceShape].include?(test_case['shape'])

        let(:generated_shape) { Object.const_get("#{subject}::#{shape}") }
        let(:expected_shape) { Object.const_get("#{shapes_module}::#{test_case['shape']}") }

        it 'is a shape of expected shape type and id' do
          expect(generated_shape).to be_a(expected_shape)
          expect(generated_shape.id).to eq(test_case['id'])
        end

        it 'has a type variation of the shape when applicable' do
          skip("Test does not expect the generated #{shape} to have a type representation") if test_case['type'].nil?

          expected_type = Object.const_get("#{types_module}::#{test_case['type']}")
          expect(generated_shape.type).to eq(expected_type)
        end

        it 'has traits when applicable and the traits does not contain omitted traits' do
          skip("Test does not expect the generated #{shape} to have traits") if test_case['traits'].nil?

          expect(generated_shape.traits).to eq(test_case['traits'])
          expect(generated_shape.traits.keys).not_to include('smithy.api#documentation')
        end

        context 'members' do
          let(:members_tests) { test_case['members'] }

          it 'are shapes of expected shape types, ids and contains ' \
             'traits when applicable' do
            skip("Test does not expect the generated #{shape} to have members") if members_tests.nil?

            members_tests.each do |m_name, m_tests|
              expect(generated_shape.members.keys).to include(m_name)

              generated_member_shape = generated_shape.members[m_name]
              expect(generated_member_shape.name).to eq(m_name)

              expected_member_shape = Object.const_get("#{subject}::#{m_tests['shape']}")
              expect(generated_member_shape.shape).to eq(expected_member_shape)
              expect(generated_member_shape.traits).to eq(m_tests['traits']) if m_tests['traits']
            end
          end
        end

        context 'member' do
          let(:member_test) { test_case['member'] }

          it 'is a shape of expected shape type, id and contains ' \
             'traits when applicable' do
            skip("Test does not expect the generated #{shape} to have a member") if member_test.nil?

            expected_member_shape =
              Object.const_get("#{subject}::#{member_test['shape']}")

            expect(generated_shape.member.name).to eq('member')
            expect(generated_shape.member.shape).to eql(expected_member_shape)
            expect(generated_shape.member.traits).to eq(member_test['traits']) if member_test['traits']
          end
        end

        context 'key and value members' do
          it 'key member is a shape of expected shape type, ids and contains ' \
             'traits when applicable' do
            skip("Test does not expect the generated #{shape} to have a key member") if test_case['key'].nil?

            expected_member_shape =
              Object.const_get("#{subject}::#{test_case['key']['shape']}")

            expect(generated_shape.member_key.name).to eq('key')
            expect(generated_shape.member_key.shape).to eq(expected_member_shape)

            if (expected_traits = test_case['key']['traits'])
              expect(generated_shape.member_key.traits).to eq(expected_traits)
            end
          end

          it 'value member is a shape of expected shape type, ids and contains ' \
             'traits when applicable' do
            skip("Test does not expect the generated #{shape} to have a value member") if test_case['value'].nil?
            expected_member_shape =
              Object.const_get("#{subject}::#{test_case['value']['shape']}")
            expect(generated_shape.member_value.name).to eq('value')
            expect(generated_shape.member_value.shape).to eq(expected_member_shape)

            if (expected_traits = test_case['value']['traits'])
              expect(generated_shape.member_key.traits).to eq(expected_traits)
            end
          end
        end
      end
    end
  end

  context 'schema' do
    it 'is a schema' do
      expect(subject::SCHEMA).to be_a(Smithy::Client::Schema)
    end

    context 'service' do
      let(:shape) { subject::SCHEMA.service }
      let(:expected_shape) { shape_tests['ServiceShape'] }

      it 'is a service shape and able to access service shape data' do
        expect(shape).to be_a(shapes_module::ServiceShape)
        expect(shape.id).to eql(expected_shape['id'])
        expect(shape.version).to eq(expected_shape['version'])
        expect(shape.traits).to eq(expected_shape['traits'])
      end
    end

    context 'operations' do
      let(:operations) { subject::SCHEMA.operations }
      let(:expected_shapes) { shape_tests.select { |_k, v| v['shape'] == 'OperationShape' } }

      it 'is not empty' do
        expect(operations).not_to be_empty
      end

      it 'made of operation shapes and able to access its contents' do
        expected_shapes.each do |name, expected_data|
          generated_shape =
            subject::SCHEMA.operation(name.underscore.to_sym)

          expect(generated_shape.id).to eq(expected_data['id'])
          expect(generated_shape.input.id).to eq(expected_data['input'])
          expect(generated_shape.output.id).to eq(expected_data['output'])

          expected_data['errors'].each do |err|
            generated_error = generated_shape.errors.find { |s| s.id == err }
            expect(generated_error.id).to eq(err)
          end
        end
      end
    end
  end
end
