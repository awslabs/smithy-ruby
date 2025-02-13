# frozen_string_literal: true

require 'bigdecimal'
require 'stringio'

module Smithy
  module Client
    describe ParamConverter do
      describe '#convert' do
        let(:union_structure) do
          Class.new(Model::Union) do
            def to_h
              { structure: super(__getobj__) }
            end
          end
        end

        it 'performs a deeply nested conversion of values' do
          client_class = ClientHelper.sample_service
          rules = client_class.const_get(:Shapes).const_get(:SCHEMA).operation(:operation).input
          structure = client_class.const_get(:Types).const_get(:Structure)

          params = structure.new(
            structure: structure.new(boolean: 'true'),
            map: 'not a map',
            structure_map: {
              'key' => structure.new(map: { color: :blue })
            },
            list: 'not a list',
            structure_list: [
              { integer: 1 },
              { integer: 2.0 },
              { integer: '3' }
            ],
            union: union_structure.new({ string: :abc })
          )

          converted = ParamConverter.convert(rules, params)
          expect(converted.to_h).to eq(
            structure: { boolean: true },
            map: 'not a map',
            structure_map: {
              'key' => { map: { 'color' => 'blue' } }
            },
            list: 'not a list',
            structure_list: [
              { integer: 1 },
              { integer: 2 },
              { integer: 3 }
            ],
            union: { structure: { string: 'abc' } }
          )
        end
      end

      context 'default conversions' do
        describe 'unknown' do
          it 'returns the value unmodified if the shape class is unknown' do
            shape_class = Class.new
            value = 'raw'
            expect(ParamConverter.c(shape_class, value)).to be(value)
          end

          it 'returns the value unmodified if the value class is unknown' do
            shape_class = Model::Shapes::StringShape
            value = double('raw')
            expect(ParamConverter.c(shape_class, value)).to be(value)
          end
        end

        describe 'big decimals' do
          let(:shape_class) { Model::Shapes::BigDecimalShape }

          it 'returns big decimals unmodified' do
            value = BigDecimal('123.456')
            expect(ParamConverter.c(shape_class, value)).to be(value)
          end

          it 'converts integers to big decimals' do
            expect(ParamConverter.c(shape_class, 123)).to eq(BigDecimal('123'))
          end

          it 'converts floats to big decimals' do
            expect(ParamConverter.c(shape_class, 123.456)).to eq(BigDecimal('123.456'))
          end

          it 'casts strings to big decimals' do
            expect(ParamConverter.c(shape_class, '123.456')).to eq(BigDecimal('123.456'))
          end

          it 'returns strings unmodified if cast fails' do
            expect(ParamConverter.c(shape_class, 'abc')).to eq('abc')
          end
        end

        describe 'blobs' do
          let(:shape_class) { Model::Shapes::BlobShape }

          it 'accepts io objects' do
            rd, wr = IO.pipe
            wr.write('abc')
            wr.close
            expect(ParamConverter.c(shape_class, rd).read).to eq('abc')
          end

          it 'accepts io objects (like file)' do
            file = File.open(__FILE__, 'r')
            expect(ParamConverter.c(shape_class, file)).to be(file)
            file.close
          end

          it 'accepts io objects (like stringio)' do
            io = StringIO.new('abc')
            expect(ParamConverter.c(shape_class, io)).to be(io)
          end

          it 'accepts io objects (like tempfiles)' do
            file = Tempfile.new('abc')
            expect(ParamConverter.c(shape_class, file)).to be(file)
            file.close
            file.delete
          end

          it 'accepts strings' do
            expect(ParamConverter.c(shape_class, 'abc')).to eq('abc')
          end

          it 'opens files that are closed' do
            file = File.open(__FILE__, 'r')
            file.close
            converter = ParamConverter.new(nil)
            expect(ParamConverter.c(shape_class, file, converter).read).to eq(File.read(__FILE__))
          end
        end

        describe 'booleans' do
          let(:shape_class) { Model::Shapes::BooleanShape }

          it 'accepts true and false' do
            expect(ParamConverter.c(shape_class, true)).to be(true)
            expect(ParamConverter.c(shape_class, false)).to be(false)
          end

          it 'accepts strings' do
            expect(ParamConverter.c(shape_class, 'true')).to be(true)
            expect(ParamConverter.c(shape_class, 'false')).to be(false)
          end

          it 'does not translate nil' do
            expect(ParamConverter.c(shape_class, nil)).to be(nil)
          end
        end

        describe 'enums' do
          let(:shape_class) { Model::Shapes::StringShape }

          it 'returns strings unmodified' do
            expect(ParamConverter.c(shape_class, 'abc')).to eq('abc')
          end

          it 'converts symbols to strings' do
            expect(ParamConverter.c(shape_class, :abc)).to eq('abc')
          end
        end

        describe 'integers' do
          let(:shape_class) { Model::Shapes::IntegerShape }

          it 'returns integers unmodified' do
            expect(ParamConverter.c(shape_class, 123)).to eq(123)
          end

          it 'converts floats to integers' do
            expect(ParamConverter.c(shape_class, 12.34)).to eq(12)
          end

          it 'casts strings to integers' do
            expect(ParamConverter.c(shape_class, '123')).to eq(123)
          end

          it 'returns strings unmodified if cast fails' do
            expect(ParamConverter.c(shape_class, 'abc')).to eq('abc')
          end
        end

        describe 'int enums' do
          let(:shape_class) { Model::Shapes::IntEnumShape }

          it 'returns integers unmodified' do
            expect(ParamConverter.c(shape_class, 123)).to eq(123)
          end

          it 'converts floats to integers' do
            expect(ParamConverter.c(shape_class, 12.34)).to eq(12)
          end

          it 'casts strings to integers' do
            expect(ParamConverter.c(shape_class, '123')).to eq(123)
          end

          it 'returns strings unmodified if cast fails' do
            expect(ParamConverter.c(shape_class, 'abc')).to eq('abc')
          end
        end

        describe 'floats' do
          let(:shape_class) { Model::Shapes::FloatShape }

          it 'returns floats unmodified' do
            expect(ParamConverter.c(shape_class, 12.34)).to eq(12.34)
          end

          it 'converts integers to floats' do
            expect(ParamConverter.c(shape_class, 12)).to eq(12.0)
          end

          it 'casts strings to floats' do
            expect(ParamConverter.c(shape_class, '12.34')).to eq(12.34)
          end

          it 'returns strings unmodified if cast fails' do
            expect(ParamConverter.c(shape_class, 'abc')).to eq('abc')
          end
        end

        describe 'lists' do
          let(:shape_class) { Model::Shapes::ListShape }

          it 'returns duplicates arrays' do
            value = [1, 2, 3]
            converted = ParamConverter.c(shape_class, value)
            expect(converted).to eq(value)
            expect(converted).not_to be(value)
          end

          it 'converts enumerables into arrays' do
            value = [1, 2, 3].enum_for(:each)
            converted = ParamConverter.c(shape_class, value)
            expect(converted).to eq([1, 2, 3])
          end
        end

        describe 'maps' do
          let(:shape_class) { Model::Shapes::MapShape }

          it 'returns duplicate hashes' do
            value = { a: 1 }
            converted = ParamConverter.c(shape_class, value)
            expect(converted).to eq(value)
            expect(converted).not_to be(value)
          end

          it 'creates a hash from a struct' do
            value = ::Struct.new(:a).new(1)
            converted = ParamConverter.c(shape_class, value)
            expect(converted).to eq(a: 1)
          end
        end

        describe 'strings' do
          let(:shape_class) { Model::Shapes::StringShape }

          it 'returns strings unmodified' do
            expect(ParamConverter.c(shape_class, 'abc')).to eq('abc')
          end

          it 'converts symbols to strings' do
            expect(ParamConverter.c(shape_class, :abc)).to eq('abc')
          end
        end

        describe 'structures' do
          let(:shape_class) { Model::Shapes::StructureShape }

          it 'returns duplicate structs' do
            value = { a: 1 }
            converted = ParamConverter.c(shape_class, value)
            expect(converted).to eq(value)
            expect(converted).not_to be(value)
          end

          it 'does not modify structs' do
            value = ::Struct.new(:a).new(1)
            converted = ParamConverter.c(shape_class, value)
            expect(converted).to be(value)
          end
        end

        describe 'timestamps' do
          let(:shape_class) { Model::Shapes::TimestampShape }

          it 'returns Time objects unmodified' do
            time = Time.now
            expect(ParamConverter.c(shape_class, time)).to be(time)
          end

          it 'returns Date objects as a Time object' do
            time = Date.new
            expect(ParamConverter.c(shape_class, time)).to eq(time.to_time)
          end

          it 'returns DateTime objects as a Time object' do
            time = DateTime.now
            expect(ParamConverter.c(shape_class, time)).to eq(time.to_time)
          end

          it 'converts integers to Time objects' do
            time = Time.now.to_i
            expect(ParamConverter.c(shape_class, time)).to eq(Time.at(time))
          end

          it 'converts floats to Time objects' do
            time = Time.now.to_f
            expect(ParamConverter.c(shape_class, time)).to eq(Time.at(time))
          end

          it 'parses strings as time objects' do
            t1 = Time.now.utc.iso8601
            t2 = Time.now.rfc822
            t3 = Time.now.to_s
            t4 = '2013-01-02'
            expect(ParamConverter.c(shape_class, t1)).to eq(Time.parse(t1))
            expect(ParamConverter.c(shape_class, t2)).to eq(Time.parse(t2))
            expect(ParamConverter.c(shape_class, t3)).to eq(Time.parse(t3))
            expect(ParamConverter.c(shape_class, t4)).to eq(Time.parse(t4))
          end

          it 'returns strings unmodified if they can not be parsed' do
            expect(ParamConverter.c(shape_class, 'abc')).to eq('abc')
          end
        end

        describe 'unions' do
          let(:shape_class) { Model::Shapes::UnionShape }

          it 'returns duplicate hashes' do
            value = { a: 1 }
            converted = ParamConverter.c(shape_class, value)
            expect(converted).to eq(value)
            expect(converted).not_to be(value)
          end

          it 'does not modify unions' do
            value = Model::Union.new(string: 'abc')
            converted = ParamConverter.c(shape_class, value)
            expect(converted).to be(value)
          end
        end
      end

      describe '.add' do
        it 'registers a new converter' do
          shape_class = Class.new
          ParamConverter.add(shape_class, String) { |s, _| s.to_sym }
          expect(ParamConverter.c(shape_class, 'abc')).to eq(:abc)
        end

        it 'can convert values based on parent value classes' do
          shape_class = Class.new
          special_string = Class.new(String)
          str = special_string.new('raw')
          ParamConverter.add(shape_class, special_string) { |_s| 'converted' }
          expect(ParamConverter.c(shape_class, str)).to eq('converted')
        end

        it 'can convert values based on parent shape classes' do
          base = Class.new
          extended = Class.new(base)
          ParamConverter.add(base, String) { |_s| 'converted' }
          expect(ParamConverter.c(extended, 'raw')).to eq('converted')
        end

        it 'replaces an existing converter' do
          shape_class = Class.new
          ParamConverter.add(shape_class, String) { |_s| 'first' }
          ParamConverter.add(shape_class, String) { |_s| 'second' }
          expect(ParamConverter.c(shape_class, 'value')).to eq('second')
        end
      end
    end
  end
end
