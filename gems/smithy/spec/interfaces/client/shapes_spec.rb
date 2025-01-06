# frozen_string_literal: true

describe 'Component: Shapes' do
  shape_tests = JSON.load_file(File.expand_path('../../fixtures/shapes/model.json', __dir__))

  before(:all) do
    @tmpdir = SpecHelper.generate(['ShapeService'], :client, fixture: 'shapes')
  end

  after(:all) do
    SpecHelper.cleanup(['ShapeService'], @tmpdir)
  end

  let(:service) { ShapeService }
  let(:types_module) { service::Types }
  let(:shapes_module) { Smithy::Client::Shapes }
  subject { service::Shapes }

  it 'generates a shapes module' do
    expect(subject).to be_a(Module)
  end

  context 'generated shapes' do
    shape_tests['shapes'].each do |id, shape|
      context 'a generated shape' do
        next if %w[operation service].include?(shape['type'])

        let(:shape_name) { Smithy::Vise::Shape.relative_id(id) }
        let(:generated_shape) { Object.const_get("#{subject}::#{shape_name}") }

        it 'is a shape of expected shape type and has an id' do
          expected_shape_type =
            Object.const_get("#{shapes_module}::#{shape['type'].camelize}Shape")

          expect(generated_shape).to be_a(expected_shape_type)
          expect(generated_shape.id).to eq(id)
        end

        it 'has a type variation of the shape when applicable' do
          skip("Test does not expect the generated #{id} to have a type") unless %w[structure union].include?(shape['type'])

          expected_type = Object.const_get("#{types_module}::#{shape_name}")
          expect(generated_shape.type).to eq(expected_type)
        end

        it 'has traits when applicable and the traits does not contain omitted traits' do
          skip("Test does not expect the generated #{id} to have traits") if shape['traits'].nil?

          expected_traits = shape['traits'].reject { |t| t == 'smithy.api#documentation' }
          expect(generated_shape.traits).to include(expected_traits)
          expect(generated_shape.traits.keys).not_to include('smithy.api#documentation')
        end

        context 'members' do
          let(:m_tests) { shape['members'] }

          it 'are shapes of expected name, shape and contains traits when applicable' do
            skip("Test does not expect the generated #{id} to have members") if m_tests.nil?

            m_tests.each do |m_name, m_test|
              m_name = m_name.underscore
              expect(generated_shape.members.keys).to include(m_name)

              generated_member_shape = generated_shape.members[m_name]
              expect(generated_member_shape.name).to eq(m_name)
              expect(generated_member_shape.shape.id).to eq(m_test['target'])

              if (expected_traits = m_test['traits'])
                expect(generated_member_shape.traits).to include(expected_traits)
              end
            end
          end
        end

        context 'member' do
          let(:m_test) { shape['member'] }

          it 'is a shape of expected member name, shape and contains traits when applicable' do
            skip("Test does not expect the generated #{id} to have a member") if m_test.nil?

            expect(generated_shape.member.name).to eq('member')
            expect(generated_shape.member.shape.id).to eq(m_test['target'])

            if (expected_traits = m_test['traits'])
              expect(generated_shape.member.traits).to include(expected_traits)
            end
          end
        end

        context 'key and value members' do
          it 'are shapes of expected member names, shapes and contains traits when applicable' do
            skip("Test does not expect the generated #{id} to have a key/value members") if shape['key'].nil? && shape['value'].nil?

            expect(generated_shape.key.name).to eq('key')
            expect(generated_shape.value.name).to eq('value')
            expect(generated_shape.key.shape.id).to eq(shape['key']['target'])
            expect(generated_shape.value.shape.id).to eq(shape['value']['target'])

            if (expected_traits = shape['key']['traits'])
              expect(generated_shape.key.traits).to include(expected_traits)
            end

            if (expected_traits = shape['value']['traits'])
              expect(generated_shape.value.traits).to include(expected_traits)
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
      let(:service_shape) { subject::SCHEMA.service }
      let(:expected_service) { shape_tests['shapes'].find { |_k, v| v['type'] == 'service' } }

      it 'is a service shape and able to access service shape data' do
        expect(service_shape).to be_a(shapes_module::ServiceShape)
        expect(service_shape.id).to eql(expected_service[0])
        expect(service_shape.version).to eq(expected_service[1]['version'])

        if (expected_traits = expected_service[1]['traits'])
          expect(service_shape.traits).to include(expected_traits)
        end
      end
    end

    context 'operations' do
      let(:operations) { subject::SCHEMA.operations }
      let(:operation_shapes) { shape_tests.select { |_k, v| v['type'] == 'operation' } }

      it 'is not empty' do
        expect(operations).not_to be_empty
      end

      it 'made of operation shapes and able to access its contents' do
        operation_shapes.each do |name, shape|
          generated_shape = subject::SCHEMA.operation(name.underscore)

          expect(generated_shape.id).to eq(name)
          expect(generated_shape.input.id).to eq(shape['input'])
          expect(generated_shape.output.id).to eq(shape['output'])

          next unless (errors = shape['errors'])

          errors.each do |err|
            generated_error = generated_shape.errors.find { |s| s.id == err }
            expect(generated_error.id).to eq(err)
          end
        end
      end
    end
  end
end
