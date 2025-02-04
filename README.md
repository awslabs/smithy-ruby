# Smithy Ruby

[Smithy](https://awslabs.github.io/smithy/) SDK code generator for Ruby.

**WARNING: This branch is under active development.  All interfaces are subject to change.**

For previous pre-release, Java based Smithy-Ruby, see: [smithy-ruby/main](https://github.com/smithy-lang/smithy-ruby/tree/main)

[![License][apache-badge]][apache-url]

[apache-badge]: https://img.shields.io/badge/License-Apache%202.0-blue.svg


## Helpful Commands

Run `smithy` gem tests:
```
bundle exec rake smithy:spec
```

Run `smithy-client` gem tests:
```
bundle exec rake smithy-client:spec
```

local build using smithy cli
```
bundle exec smithy build --debug model/weather.smithy
```

local build using smithy-ruby executable:
```
export SMITHY_PLUGIN_DIR=build/smithy/source/smithy-ruby
bundle exec smithy-ruby smith client --gem-name weather --gem-version 1.0.0 --destination-root projections/weather <<< $(smithy ast model/weather.smithy)
```

IRB on `weather` gem:
```
irb -I projections/weather/lib -I gems/smithy-client/lib -r weather
```

Create a Weather client:
```
client = Weather::Client.new(endpoint: 'https://example.com')
client.get_current_time
```

Build a fixture
```
export SMITHY_PLUGIN_DIR=build/smithy/source/smithy-ruby
bundle exec smithy-ruby smith client --gem-name fixture --gem-version 1.0.0 <<< $(cat gems/smithy/spec/fixtures/endpoints/default-values/model.json)
```

Running RBS validations and tests:
```
bundle exec rake smithy-client:rbs
bundle exec rake smithy:rbs
```
