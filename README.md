# Cache Hash

A simple key value store where pairs can expire after a set interval

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  cache_hash:
    github: samueleaton/cache_hash
```

## Usage Example

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

## API

### `CacheHash(K, V)`

Defines the types for the keys and values.

#### Example

```ruby
CacheHash(String, String).new(Time::Span(0, 1, 0))
```

### `.new(cache_time_span : Time::Span)`

Creates a new instance of `CacheHash` with the and sets the cache interval.

### `.set(key : K, value : V)`

Adds a key/value pair to the hash where `K` and `V` are the types defined at `CacheHash(K, V)`.

### `.get(key : K) : V | Nil`

Returns the value for the the associated key. If the pair is stale (expired) or does not exists, it returns `nil`. If it exists but is expired, it is deleted before returning `nil`.
 
### `.purge_stale`

Removes all stale key/value pairs from the hash.

### `.fresh() : Array(K)`

Runs `purge_stale` and returns an array of all the the non-stale keys.

### `.fresh?(key : K) : Bool`

Returns `true` if the key/value pair exists and is not stale. If the pair is stale (expired) or does not exists, it returns `false`. If it exists but is expired, it is deleted before returning `false`.

### `.time(key : K) : Time`

Returns the time the key/value pair was cached. If the pair is stale (expired) or does not exists, it returns `nil`. If it exists but is expired, it is deleted before returning `nil`.

## Contributing

1. Fork it ( https://github.com/[your-github-name]/cache_hash/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Sam Eaton](https://github.com/samueleaton) - creator, maintainer
