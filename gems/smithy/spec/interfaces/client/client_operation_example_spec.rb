# frozen_string_literal: true

describe 'Component: Client: Request/Response Syntax Examples' do
  let(:rdoc) do
    require 'rdoc'
    rdoc = RDoc::RDoc.new
    rdoc.options = RDoc::Options.load_options
    rdoc.store = RDoc::Store.new
    rdoc
  end

  before(:all) do
    @tmpdir = SpecHelper.generate(['Examples'], :client)
  end

  after(:all) do
    SpecHelper.cleanup(['Examples'], @tmpdir)
  end

  it 'generates operation examples' do
    expected = <<~EXAMPLE
      @example Example
        # This is an example
        params = {
          string: "input",
          structure: {
            string: "structure"
          },
          list: [
            {
              string: "list"
            }
          ],
          map: {
            "mapKey" => {
              string: "map value"
            }
          }
        }
        options = {}
        output = client.operation(params, options)
        output.to_h #=>
        {
          string: "output",
          structure: {
            string: "structure"
          },
          list: [
            {
              string: "list"
            }
          ],
          map: {
            "mapKey" => {
              string: "map value"
            }
          }
        }
      @example Error Example
        # This is an example with errors
        params = {
          string: "bad input",
          structure: {
            string: "structure"
          },
          list: [
            {
              string: "list"
            }
          ],
          map: {
            "mapKey" => {
              string: "map value"
            }
          }
        }
        options = {}
        begin
          output = client.operation(params, options)
        rescue Smithy::Client::Errors::ServiceError => e
          puts e.class #=> Error
          puts e.data.to_h #=>
          {
            message: "This is an error"
          }
        end
    EXAMPLE
    client_file = File.join(@tmpdir, 'lib', 'examples', 'client.rb')
    top_level = rdoc.parse_files([client_file]).first
    actual = top_level.find_class_or_module('Examples::Client').find_method_named('operation')
    expect(actual.comment.text).to include(expected.chomp)
  end
end
