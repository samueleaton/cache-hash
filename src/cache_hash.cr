class CacheHash(V)
  def initialize(@cache_time_span : Time::Span)
    @kv_hash = {} of String => V
    @time_hash = {} of String => Time
    @is_purge_interval_running = false
  end

  def get(key : String)
    if cached_time = @time_hash[key]?
      if cached_time > Time.now - @cache_time_span
        @kv_hash[key]
      else
        delete key
        nil
      end
    end
  end

  def set(key : String, val : V | Nil)
    if val.nil?
      delete key
    else
      @time_hash[key] = Time.now
      @kv_hash[key] = val
    end
  end

  private def delete(key : String) : Nil
    @time_hash.delete key
    @kv_hash.delete key
    nil
  end

  def purge_stale
    @kv_hash.each_key do |key|
      if cached_time = @time_hash[key]?
        delete key unless cached_time > Time.now - @cache_time_span
      end
    end
  end

  def purge
    @time_hash.clear
    @kv_hash.clear
    nil
  end

  def keys
    purge_stale
    @kv_hash.keys
  end

  def fresh?(key : String)
    if cached_time = @time_hash[key]?
      if cached_time > Time.now - @cache_time_span
        true
      else
        delete key
        false
      end
    else
      false
    end
  end

  def time(key : String)
    if cached_time = @time_hash[key]?
      if cached_time > Time.now - @cache_time_span
        cached_time
      else
        delete key
      end
    end
  end

  def refresh(key : String)
    if cached_time = @time_hash[key]?
      if cached_time > Time.now - @cache_time_span
        @time_hash[key] = Time.now
        @kv_hash[key]
      else
        delete key
        nil
      end
    end
  end

  def set_purge_interval(interval : Time::Span, stale_only = true)
    @purge_interval = interval
    @purge_interval_stale_only = stale_only
    unless @is_purge_interval_running
      spawn do
        run_purge_interval_loop
      end
    end
  end

  private def run_purge_interval_loop
    return if @is_purge_interval_running

    @is_purge_interval_running = true
    loop do
      stale_only = @purge_interval_stale_only
      if (interval = @purge_interval).is_a?(Time::Span)
        sleep interval.as(Time::Span)
        if stale_only
          purge_stale
        else
          purge
        end
      end
    end
  end
end
