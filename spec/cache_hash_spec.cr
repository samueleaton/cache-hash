require "./spec_helper"

describe CacheHash do
  it "saves key value pairs" do
    hash = CacheHash(String, String).new(Time::Span.new(0,0,4))
    hash["city_1"] = "Seattle"
    hash["city_2"] = "Honk Kong"
    hash["city_3"] = "Sacramento"
    hash["city_1"].should eq("Seattle")
    hash["city_2"].should eq("Honk Kong")
    hash["city_3"].should eq("Sacramento")
  end

  it "removes stale kv pairs on lookup" do
    hash = CacheHash(String, String).new(Time::Span.new(0,0,3))
    hash["city_1"] = "Seattle"
    sleep 1
    hash["city_2"] = "Honk Kong"
    sleep 1
    hash["city_3"] = "Sacramento"
    sleep 1
    hash["city_4"] = "Salt Lake City"
    sleep 1
    hash["city_5"] = "Denver"
    sleep 1

    hash.raw["city_1"].should eq("Seattle")
    hash.raw["city_2"].should eq("Honk Kong")
    hash.raw["city_3"].should eq("Sacramento")
    hash.raw["city_4"].should eq("Salt Lake City")
    hash.raw["city_5"].should eq("Denver")

    hash["city_1"].should be_nil
    hash["city_2"].should be_nil
    hash["city_3"].should be_nil
    hash["city_4"].should eq("Salt Lake City")
    hash["city_5"].should eq("Denver")

    hash.raw["city_1"]?.should be_nil
    hash.raw["city_2"]?.should be_nil
    hash.raw["city_3"]?.should be_nil
    hash.raw["city_4"]?.should eq("Salt Lake City")
    hash.raw["city_5"]?.should eq("Denver")
  end

  describe "#purge_stale" do
    it "removes all stale, expired values from the hash" do
      hash = CacheHash(String, String).new(Time::Span.new(0,0,3))
      hash["city_1"] = "Seattle"
      sleep 1
      hash["city_2"] = "Honk Kong"
      sleep 1
      hash["city_3"] = "Sacramento"
      sleep 1
      hash["city_4"] = "Salt Lake City"
      sleep 1
      hash["city_5"] = "Denver"
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

  describe "#fresh" do
    it "purges all stale values and returns the IDs of non-stale kv pairs" do
      hash = CacheHash(String, String).new(Time::Span.new(0,0,3))
      hash["city_1"] = "Seattle"
      sleep 1
      hash["city_2"] = "Honk Kong"
      sleep 1
      hash["city_3"] = "Sacramento"
      sleep 1
      hash["city_4"] = "Salt Lake City"
      sleep 1
      hash["city_5"] = "Denver"
      sleep 1
      
      hash.raw["city_1"].should eq("Seattle")
      hash.raw["city_2"].should eq("Honk Kong")
      hash.raw["city_3"].should eq("Sacramento")
      hash.raw["city_4"].should eq("Salt Lake City")
      hash.raw["city_5"].should eq("Denver")

      hash.fresh.should eq(["city_4", "city_5"])

      hash.raw["city_1"]?.should be_nil
      hash.raw["city_2"]?.should be_nil
      hash.raw["city_3"]?.should be_nil
      hash.raw["city_4"]?.should eq("Salt Lake City")
      hash.raw["city_5"]?.should eq("Denver")
    end
  end

  describe "#fresh?" do
    it "returns a true if the kv pair is not stale" do
      hash = CacheHash(String, String).new(Time::Span.new(0,0,3))
      hash["city_1"] = "Seattle"
      sleep 1
      hash["city_2"] = "Honk Kong"
      sleep 1
      hash["city_3"] = "Sacramento"
      sleep 1
      hash["city_4"] = "Salt Lake City"
      sleep 1
      hash["city_5"] = "Denver"
      sleep 1
      
      hash.fresh?("city_1").should be_false
      hash.fresh?("city_4").should be_true
      hash.fresh?("xxxxx").should be_false
      sleep 2
      hash.fresh?("city_4").should be_false
    end

    it "removes deletes the kv pair if it is stale" do
      hash = CacheHash(String, String).new(Time::Span.new(0,0,3))
      hash["city_1"] = "Seattle"
      sleep 1
      hash["city_2"] = "Honk Kong"
      sleep 1
      hash["city_3"] = "Sacramento"
      sleep 1
      hash["city_4"] = "Salt Lake City"
      sleep 1
      hash["city_5"] = "Denver"
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
      hash = CacheHash(String, String).new(Time::Span.new(0,0,3))
      
      t = Time.now
      hash["city_1"] = "Seattle"
      hash.time("city_1").class.should eq(Time)
      
      city_1_time = hash.time("city_1").not_nil!
      (city_1_time > t && city_1_time < Time.now).should be_true
    end

    it "delete the kv pair if it is stale" do
      hash = CacheHash(String, String).new(Time::Span.new(0,0,3))
      hash["city_1"] = "Seattle"
      sleep 1
      hash["city_2"] = "Honk Kong"
      sleep 1
      hash["city_3"] = "Sacramento"
      sleep 1
      hash["city_4"] = "Salt Lake City"
      sleep 1
      hash["city_5"] = "Denver"
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
end
