# frozen_string_literal: true

describe 'Component: Client: Request/Response Syntax Examples' do
  before(:all) do
    @tmpdir = SpecHelper.generate(['SyntaxExamples'], :client)
  end

  after(:all) do
    SpecHelper.cleanup(['SyntaxExamples'], @tmpdir)
  end

  it 'generates request and response syntax examples' do
    expected = <<~EXAMPLE
      @example Request syntax with placeholder values
        params = {
          blob: "data",
          streaming_blob: File.read("source_file"), # required
          boolean: false,
          string: "String",
          byte: 97,
          short: 1,
          integer: 1,
          long: 1,
          float: 1.0,
          double: 1.0,
          big_integer: 1,
          big_decimal: BigDecimal(1),
          timestamp: Time.now,
          document: TODO: document,
          enum: "VALUE" # One of: ["VALUE"],
          int_enum: 0 # One of: [0],
          simple_list: ["String"],
          complex_list: [
            {
              member: "String"
            }
          ],
          simple_map: {
            "String" => "String"
          },
          complex_map: {
            "String" => {
              member: "String"
            }
          },
          structure: {
            member: "String"
          },
          union: TODO: union
        }
        options = {}
        output = client.operation(params, options)
      @example Response structure with placeholder values
        output.to_h #=>
        {
          blob: "data",
          streaming_blob: File.read("source_file"), # required
          boolean: false,
          string: "String",
          byte: 97,
          short: 1,
          integer: 1,
          long: 1,
          float: 1.0,
          double: 1.0,
          big_integer: 1,
          big_decimal: BigDecimal(1),
          timestamp: Time.now,
          document: TODO: document,
          enum: "VALUE" # One of: ["VALUE"],
          int_enum: 0 # One of: [0],
          simple_list: ["String"],
          complex_list: [
            {
              member: "String"
            }
          ],
          simple_map: {
            "String" => "String"
          },
          complex_map: {
            "String" => {
              member: "String"
            }
          },
          structure: {
            member: "String"
          },
          union: TODO: union
        }
    EXAMPLE
    client_file = File.join(@tmpdir, 'lib', 'syntax_examples', 'client.rb')
    expect(expected).to be_in_documentation(client_file, 'SyntaxExamples::Client', 'operation')
  end

  context 'recursive shapes' do
    before(:all) do
      @tmpdir = SpecHelper.generate(['Recursive'], :client)
    end

    after(:all) do
      SpecHelper.cleanup(['Recursive'], @tmpdir)
    end

    it 'handles recursive shapes' do
      expected = <<~EXAMPLE
        @example Request syntax with placeholder values
          params = {
            structure: {
              structure: {
                # recursive Structure
              }
            }
          }
          options = {}
          output = client.operation(params, options)
        @example Response structure with placeholder values
          output.to_h #=>
          {
            structure: {
              structure: {
                # recursive Structure
              }
            }
          }
      EXAMPLE
      client_file = File.join(@tmpdir, 'lib', 'recursive', 'client.rb')
      expect(expected).to be_in_documentation(client_file, 'Recursive::Client', 'operation')
    end
  end
end
