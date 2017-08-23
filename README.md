# Cache Hash

A simple key value store where pairs can expire after a set interval

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  cache_hash:
    github: samueleaton/cache_hash
```

## Usage

```ruby
require "cache_hash"

# (Hours, Minutes, Seconds), caching 2 seconds
cache_interval = Time::Span.new(0, 0, 2)

cache_hash = CacheHash(String, String).new(cache_interval)
cache_hash.set "key1", "Value 1"
sleep 1 # one second elapsed
cache_hash.set "key2", "Value 2"
sleep 1 # two seconds elapsed

cache_hash.get "key1" #=> nil
cache_hash.get "key2" #=> "Value 2"
```

## Contributing

1. Fork it ( https://github.com/[your-github-name]/cache_hash/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Sam Eaton](https://github.com/samueleaton) - creator, maintainer
