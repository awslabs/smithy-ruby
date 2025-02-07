# frozen_string_literal: true

describe 'Client: Request/Response Syntax Examples' do
  include_context 'generated client gem', fixture: 'examples_trait'

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
    client_file = File.join(@plan.destination_root, 'lib', 'examples_trait', 'client.rb')
    expect(expected).to be_in_documentation(client_file, 'ExamplesTrait::Client', 'operation')
  end
end
