# TODO

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
irb -I build/smithy/weather/smithy-ruby/lib -I gems/smithy-client/lib -r weather
```

Create a Weather client:
```
client = Weather::Client.new(endpoint: 'https://example.com')
client.get_current_time
```