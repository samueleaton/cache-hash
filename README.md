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

cache_hash = CacheHash(String).new(cache_interval)
cache_hash.set "key1", "Value 1"
sleep 1 # one second elapsed
cache_hash.set "key2", "Value 2"
sleep 1 # two seconds elapsed

cache_hash.get "key1" #=> nil
cache_hash.get "key2" #=> "Value 2"
```

## API

### `CacheHash(V)`

Defines the type(s) for the values.

#### Example

```ruby
CacheHash(String).new(Time::Span(0, 1, 0))
```

### `.new(cache_time_span : Time::Span)`

Creates a new instance of `CacheHash` and sets the cache interval.

### `.set(key : String, value : V)`

Adds a key/value pair to the hash, where `V` is the type(s) defined at `CacheHash(V)`, and saves the time of the action.

### `.get(key : String) : V | Nil`

Returns the value for the the associated key. If the pair is stale (expired) or does not exists, it returns `nil`. If it exists but is expired, it is deleted before returning `nil`.
 
### `.purge_stale`

Removes all stale key/value pairs from the hash.

### `.keys() : Array(String)`

Runs `purge_stale` and returns an array of all the the non-stale keys.

### `.fresh?(key : String) : Bool`

Returns `true` if the key/value pair exists and is not stale. If the pair is stale (expired) or does not exists, it returns `false`. If it exists but is expired, it is deleted before returning `false`.

### `.time(key : String) : Time`

Returns the time the key/value pair was cached. If the pair is stale (expired) or does not exists, it returns `nil`. If it exists but is expired, it is deleted before returning `nil`.

## Contributing

1. Fork it ( https://github.com/[your-github-name]/cache_hash/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Sam Eaton](https://github.com/samueleaton) - creator, maintainer
