# frozen_string_literal: true

require "test_helper"

class FiveMileRefreshJobTest < ActiveJob::TestCase
  KYIV = [50.44, 30.51]

  setup do
    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rails.cache = @original_cache
    ENV.delete("MYLOC")
  end

  test "refreshes the candidates around the given point" do
    locus = create(:locus, lat: 50.45, lon: 30.52, five_mile_radius: false)

    FiveMileRefreshJob.perform_now(*KYIV)

    assert_includes Rails.cache.read("5mr/candidates").pluck(:locus_id), locus.id
  end

  test "falls back to the home location from the environment" do
    locus = create(:locus, lat: 50.45, lon: 30.52, five_mile_radius: false)
    ENV["MYLOC"] = "50.44, 30.51"

    FiveMileRefreshJob.perform_now

    assert_includes Rails.cache.read("5mr/candidates").pluck(:locus_id), locus.id
  end

  test "the home location is also used when only one coordinate is given" do
    locus = create(:locus, lat: 50.45, lon: 30.52, five_mile_radius: false)
    ENV["MYLOC"] = "50.44, 30.51"

    FiveMileRefreshJob.perform_now(50.44)

    assert_includes Rails.cache.read("5mr/candidates").pluck(:locus_id), locus.id
  end

  test "runs on the low priority queue" do
    assert_equal "low", FiveMileRefreshJob.new.queue_name
  end
end
