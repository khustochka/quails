# frozen_string_literal: true

require "test_helper"
require "quails/five_mile_radius"

class FiveMileRadiusTest < ActiveSupport::TestCase
  KYIV = [50.44, 30.51]

  test "latitude and longitude are required" do
    assert_raise(RuntimeError) { Quails::FiveMileRadius.new(nil, nil) }
    assert_raise(RuntimeError) { Quails::FiveMileRadius.new(50.44, nil) }
    assert_raise(RuntimeError) { Quails::FiveMileRadius.new(nil, 30.51) }
  end

  test "a locus within five miles is a candidate for adding" do
    locus = create(:locus, lat: 50.45, lon: 30.52, five_mile_radius: false)

    addition, = Quails::FiveMileRadius.new(*KYIV).candidates

    assert_includes addition.pluck(:locus_id), locus.id
  end

  test "a locus further than five miles is not a candidate for adding" do
    locus = create(:locus, lat: 50.51, lon: 30.79, five_mile_radius: false)

    addition, = Quails::FiveMileRadius.new(*KYIV).candidates

    assert_not_includes addition.pluck(:locus_id), locus.id
  end

  test "a locus already in the 5MR is not offered for adding again" do
    locus = create(:locus, lat: 50.45, lon: 30.52, five_mile_radius: true)

    addition, = Quails::FiveMileRadius.new(*KYIV).candidates

    assert_not_includes addition.pluck(:locus_id), locus.id
  end

  test "a locus in the 5MR but further than five miles is a candidate for removal" do
    locus = create(:locus, lat: 50.51, lon: 30.79, five_mile_radius: true)

    _, removal = Quails::FiveMileRadius.new(*KYIV).candidates

    assert_includes removal.pluck(:locus_id), locus.id
  end

  test "loci without coordinates are ignored" do
    locus = create(:locus, lat: nil, lon: nil, five_mile_radius: false)

    addition, removal = Quails::FiveMileRadius.new(*KYIV).candidates

    assert_not_includes addition.pluck(:locus_id), locus.id
    assert_not_includes removal.pluck(:locus_id), locus.id
  end

  test "candidates carry the distance in miles" do
    create(:locus, lat: 50.44, lon: 30.51, five_mile_radius: false)

    addition, = Quails::FiveMileRadius.new(*KYIV).candidates

    assert_in_delta 0.0, addition.first[:distance], 0.01
  end

  test "distance is measured with the haversine formula" do
    create(:locus, lat: 50.51, lon: 30.79, five_mile_radius: true)

    _, removal = Quails::FiveMileRadius.new(*KYIV).candidates

    # Kyiv to Brovary is roughly 13 miles.
    assert_in_delta 13.0, removal.first[:distance], 1.0
  end

  test "refresh stores both candidate lists in the cache" do
    near = create(:locus, lat: 50.45, lon: 30.52, five_mile_radius: false)
    far = create(:locus, lat: 50.51, lon: 30.79, five_mile_radius: true)

    original = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    Quails::FiveMileRadius.new(*KYIV).refresh

    assert_includes Rails.cache.read("5mr/candidates").pluck(:locus_id), near.id
    assert_includes Rails.cache.read("5mr/removal").pluck(:locus_id), far.id
  ensure
    Rails.cache = original
  end
end
