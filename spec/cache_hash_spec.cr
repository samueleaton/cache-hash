require "./spec_helper"

describe CacheHash do
  it "saves key value pairs" do
    hash = CacheHash(String).new(4.seconds)
    hash.set "city_1", "Seattle"
    hash.set "city_2", "Honk Kong"
    hash.set "city_3", "Sacramento"
    hash.get("city_1").should eq("Seattle")
    hash.get("city_2").should eq("Honk Kong")
    hash.get("city_3").should eq("Sacramento")
  end

  it "allows different value types" do
    hash = CacheHash(Int32).new(Time::Span.new(0, 0, 4))
    hash.set "key1", 1111
    hash.set "key2", 2222
    hash.set "key3", 3333
    hash.get("key1").should eq(1111)
    hash.get("key2").should eq(2222)
    hash.get("key3").should eq(3333)

    hash2 = CacheHash(Int32 | String | Bool).new(Time::Span.new(0, 0, 4))
    hash2.set "key1", 1111
    hash2.set "key2", "two"
    hash2.set "key3", false
    hash2.get("key1").should eq(1111)
    hash2.get("key2").should eq("two")
    hash2.get("key3").should eq(false)
  end

  it "removes stale kv pairs on lookup" do
    hash = CacheHash(String).new(3.seconds)
    hash.set "city_1", "Seattle"
    sleep 1
    hash.set "city_2", "Honk Kong"
    sleep 1
    hash.set "city_3", "Sacramento"
    sleep 1
    hash.set "city_4", "Salt Lake City"
    sleep 1
    hash.set "city_5", "Denver"
    sleep 1

    hash.raw["city_1"].should eq("Seattle")
    hash.raw["city_2"].should eq("Honk Kong")
    hash.raw["city_3"].should eq("Sacramento")
    hash.raw["city_4"].should eq("Salt Lake City")
    hash.raw["city_5"].should eq("Denver")

    hash.get("city_1").should be_nil
    hash.get("city_2").should be_nil
    hash.get("city_3").should be_nil
    hash.get("city_4").should eq("Salt Lake City")
    hash.get("city_5").should eq("Denver")

    hash.raw["city_1"]?.should be_nil
    hash.raw["city_2"]?.should be_nil
    hash.raw["city_3"]?.should be_nil
    hash.raw["city_4"]?.should eq("Salt Lake City")
    hash.raw["city_5"]?.should eq("Denver")
  end

  describe "#purge_stale" do
    it "removes all stale, expired values from the hash" do
      hash = CacheHash(String).new(Time::Span.new(0, 0, 3))
      hash.set "city_1", "Seattle"
      sleep 1
      hash.set "city_2", "Honk Kong"
      sleep 1
      hash.set "city_3", "Sacramento"
      sleep 1
      hash.set "city_4", "Salt Lake City"
      sleep 1
      hash.set "city_5", "Denver"
      sleep 1
      hash.raw["city_1"].should eq("Seattle")
      hash.raw["city_2"].should eq("Honk Kong")
      hash.raw["city_3"].should eq("Sacramento")
      hash.raw["city_4"].should eq("Salt Lake City")
      hash.raw["city_5"].should eq("Denver")
      hash.purge_stale
      hash.raw["city_1"]?.should be_nil
      hash.raw["city_2"]?.should be_nil
      hash.raw["city_3"]?.should be_nil
      hash.raw["city_4"]?.should eq("Salt Lake City")
      hash.raw["city_5"]?.should eq("Denver")
    end
  end

  describe "#keys" do
    it "purges all stale values and returns the IDs of non-stale kv pairs" do
      hash = CacheHash(String).new(Time::Span.new(0, 0, 3))
      hash.set "city_1", "Seattle"
      sleep 1
      hash.set "city_2", "Honk Kong"
      sleep 1
      hash.set "city_3", "Sacramento"
      sleep 1
      hash.set "city_4", "Salt Lake City"
      sleep 1
      hash.set "city_5", "Denver"
      sleep 1

      hash.raw["city_1"].should eq("Seattle")
      hash.raw["city_2"].should eq("Honk Kong")
      hash.raw["city_3"].should eq("Sacramento")
      hash.raw["city_4"].should eq("Salt Lake City")
      hash.raw["city_5"].should eq("Denver")

      hash.keys.should eq(["city_4", "city_5"])

      hash.raw["city_1"]?.should be_nil
      hash.raw["city_2"]?.should be_nil
      hash.raw["city_3"]?.should be_nil
      hash.raw["city_4"]?.should eq("Salt Lake City")
      hash.raw["city_5"]?.should eq("Denver")
    end
  end

  describe "#fresh?" do
    it "returns a true if the kv pair is not stale" do
      hash = CacheHash(String).new(Time::Span.new(0, 0, 3))
      hash.set "city_1", "Seattle"
      sleep 1
      hash.set "city_2", "Honk Kong"
      sleep 1
      hash.set "city_3", "Sacramento"
      sleep 1
      hash.set "city_4", "Salt Lake City"
      sleep 1
      hash.set "city_5", "Denver"
      sleep 1

      hash.fresh?("city_1").should be_false
      hash.fresh?("city_4").should be_true
      hash.fresh?("xxxxx").should be_false
      sleep 2
      hash.fresh?("city_4").should be_false
    end

    it "removes deletes the kv pair if it is stale" do
      hash = CacheHash(String).new(Time::Span.new(0, 0, 3))
      hash.set "city_1", "Seattle"
      sleep 1
      hash.set "city_2", "Honk Kong"
      sleep 1
      hash.set "city_3", "Sacramento"
      sleep 1
      hash.set "city_4", "Salt Lake City"
      sleep 1
      hash.set "city_5", "Denver"
      sleep 1

      hash.raw["city_1"].should eq("Seattle")
      hash.raw["city_2"].should eq("Honk Kong")
      hash.raw["city_3"].should eq("Sacramento")
      hash.raw["city_4"].should eq("Salt Lake City")
      hash.raw["city_5"].should eq("Denver")

      (hash.fresh?("city_1")).should be_false
      hash.raw["city_1"]?.should be_nil
    end
  end

  describe "#time" do
    it "returns a time if the kv pair is not stale" do
      time_before = Time.now
      sleep 1
      hash = CacheHash(String).new(3.seconds)
      hash.set "city_1", "Seattle"
      sleep 1
      time_after = Time.now

      city_1_time = hash.time("city_1").not_nil!
      city_1_time.class.should eq(Time)
      (city_1_time > time_before).should be_true
      (city_1_time < time_after).should be_true
    end

    it "delete the kv pair if it is stale" do
      hash = CacheHash(String).new(Time::Span.new(0, 0, 3))
      hash.set "city_1", "Seattle"
      sleep 1
      hash.set "city_2", "Honk Kong"
      sleep 1
      hash.set "city_3", "Sacramento"
      sleep 1
      hash.set "city_4", "Salt Lake City"
      sleep 1
      hash.set "city_5", "Denver"
      sleep 1

      hash.raw["city_1"].should eq("Seattle")
      hash.raw["city_2"].should eq("Honk Kong")
      hash.raw["city_3"].should eq("Sacramento")
      hash.raw["city_4"].should eq("Salt Lake City")
      hash.raw["city_5"].should eq("Denver")

      hash.time("city_1").should be_nil
      hash.raw["city_1"]?.should be_nil
    end
  end

  describe "#refresh" do
    it "refreshes the expiration time" do
      hash = CacheHash(String).new(Time::Span.new(0, 0, 3))

      hash.set "city_1", "Seattle"
      sleep 1

      hash.set "city_2", "Hong Kong"
      sleep 1

      hash.refresh "city_1"

      hash.set "city_3", "Sacramento"
      sleep 1

      hash.refresh "city_2"

      hash.set "city_4", "Salt Lake City"
      sleep 1

      hash.refresh "city_2"

      hash.set "city_5", "Denver"

      hash.get("city_1").should eq("Seattle")
      sleep 1

      hash.get("city_1").should be_nil
      hash.get("city_2").should eq("Hong Kong")
      hash.get("city_3").should be_nil
      hash.get("city_4").should eq("Salt Lake City")
      hash.get("city_5").should eq("Denver")

      sleep 1

      hash.get("city_2").should eq("Hong Kong")
      hash.get("city_4").should be_nil

      sleep 1
      hash.get("city_2").should be_nil
    end
    it "returns the value on success" do
      hash = CacheHash(String).new(Time::Span.new(0, 0, 3))

      hash.set "city_1", "Seattle"
      sleep 1

      hash.refresh("city_1").should eq("Seattle")
    end
    it "returns nil if no key or if already expires" do
      hash = CacheHash(String).new(Time::Span.new(0, 0, 3))

      hash.set "city_1", "Seattle"
      sleep 1

      hash.set "city_2", "Hong Kong"
      sleep 1

      hash.refresh("city_2").should eq("Hong Kong")
      sleep 1

      hash.refresh("city_1").should be_nil
      hash.refresh("city_3").should be_nil
    end
  end

  describe "#purge" do
    it "purges all values from cache" do
      hash = CacheHash(String).new(5.seconds)
      hash.set "city_1", "Seattle"
      hash.set "city_2", "Honk Kong"
      hash.set "city_3", "Sacramento"
      hash.purge
      hash.get("city_1").should be_nil
      hash.get("city_2").should be_nil
      hash.get("city_3").should be_nil
      hash.raw.empty?.should be_true
    end
  end

  describe "#set_purge_interval" do
    it "purges stale values from hash" do
      hash = CacheHash(String).new(4.seconds)
      hash.set_purge_interval(3.seconds)
      hash.set "city_1", "Seattle"
      hash.set "city_2", "Hong Kong"
      hash.set "city_3", "Sacramento"

      hash.get("city_1").should eq("Seattle")
      hash.get("city_2").should eq("Hong Kong")
      hash.get("city_3").should eq("Sacramento")
      hash.raw.empty?.should be_false
      sleep 4
      hash.get("city_1").should be_nil
      hash.get("city_2").should be_nil
      hash.get("city_3").should be_nil
      hash.raw.empty?.should be_true

      hash.set "city_1", "Seattle"
      sleep 2
      hash.set "city_2", "Hong Kong"
      hash.get("city_1").should eq("Seattle")
      hash.get("city_2").should eq("Hong Kong")
      sleep 2
      hash.get("city_1").should be_nil
      hash.get("city_2").should eq("Hong Kong")
      sleep 2
      hash.get("city_1").should be_nil
      hash.get("city_2").should be_nil
      hash.raw.empty?.should be_true
    end

    it "purges all values from hash if specified" do
      hash = CacheHash(String).new(5.seconds)
      hash.set_purge_interval(3.seconds, stale_only: false)
      hash.set "city_1", "Seattle"
      hash.set "city_2", "Hong Kong"
      hash.set "city_3", "Sacramento"

      hash.get("city_1").should eq("Seattle")
      hash.get("city_2").should eq("Hong Kong")
      hash.get("city_3").should eq("Sacramento")
      hash.raw.empty?.should be_false
      sleep 4
      hash.get("city_1").should be_nil
      hash.get("city_2").should be_nil
      hash.get("city_3").should be_nil
      hash.raw.empty?.should be_true
    end
  end
end
