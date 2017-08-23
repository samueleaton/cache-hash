class CacheHash(K, T)
  def initialize(@cache_time_span : Time::Span)
    @kv_hash = {} of K => String
    @time_hash = {} of K => Time
  end
  
  def get(key)
    if cached_time = @time_hash[key]?
      if cached_time > Time.now - @cache_time_span
        @kv_hash[key]
      else
        delete key
        nil
      end
    end
  end
  
  def set(key, val : T | Nil)
    if val.nil?
      delete key
    else
      @time_hash[key] = Time.now
      @kv_hash[key] = val
    end
  end

  private def delete(key) : String | Nil
    @time_hash.delete key
    @kv_hash.delete key
    nil
  end

  def purge_stale()
    @kv_hash.select! do |k, v|
      if cached_time = @time_hash[k]?
        cached_time > Time.now - @cache_time_span
      end
    end
    nil
  end

  def keys
    purge_stale
    @kv_hash.keys
  end

  def fresh?(k)
    if cached_time = @time_hash[k]?
      if cached_time > Time.now - @cache_time_span
        true
      else
        delete k
        false
      end
    else
      false
    end
  end

  def time(k)
    if cached_time = @time_hash[k]?
      if cached_time > Time.now - @cache_time_span
        cached_time
      else
        delete k
      end
    end
  end
end
