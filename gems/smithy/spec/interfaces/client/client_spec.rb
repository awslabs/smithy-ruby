# frozen_string_literal: true

describe 'Component: Client' do
  before(:all) do
    @tmpdir = SpecHelper.generate(['Weather'], :client)
  end

  after(:all) do
    SpecHelper.cleanup(['Weather'], @tmpdir)
  end

  subject { Weather::Client.new }

  it 'adds the HTTP plugin' do
    expect(Weather::Client.plugins).to include(Smithy::Client::Plugins::NetHTTP)
  end

  it 'has operation methods' do
    expect(subject).to respond_to(:get_city, :get_current_time, :get_forecast, :list_cities)
  end

  # it 'builds input for operations' do
  #   input = subject.send(:build_input, :get_city, { id: 1 })
  #   expect(input).to be_a(Smithy::Client::Input)
  # end

  # it 'can call operations' do
  #   subject.get_city(id: 1)
  # end

  context 'request example documentation' do
    before(:all) do
      @tmpdir = SpecHelper.generate(['AllShapes'], :client)
    end

    after(:all) do
      SpecHelper.cleanup(['AllShapes'], @tmpdir)
    end

    it 'generates request syntax examples' do
      expected = <<~EXAMPLE
        @example Request syntax with placeholder values

          output = client.operation(
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
          )
      EXAMPLE
      require 'rdoc'
      rdoc = RDoc::RDoc.new
      rdoc.options = RDoc::Options.load_options
      rdoc.store = RDoc::Store.new
      client_file = File.join(@tmpdir, 'lib', 'all_shapes', 'client.rb')
      top_level = rdoc.parse_files([client_file]).first
      actual = top_level.find_class_or_module('AllShapes::Client').find_method_named('operation')
      expect(actual.comment.text).to eq(expected.chomp)
    end
  end
end
