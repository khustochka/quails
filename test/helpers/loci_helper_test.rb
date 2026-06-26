# frozen_string_literal: true

require "test_helper"

class LociHelperTest < ActionView::TestCase
  test "latlon_link links to Google Maps when both coordinates present" do
    locus = build(:locus, lat: 50.51, lon: 30.79)
    html = latlon_link(locus)
    assert_includes html, %(href="https://www.google.com/maps?q=50.51,30.79")
    assert_includes html, "50.5100;30.7900"
  end

  test "latlon_link returns a dash when coordinates are blank" do
    locus = build(:locus, lat: nil, lon: nil)
    assert_equal "—", latlon_link(locus)
  end

  test "latlon_link returns plain text when only one coordinate present" do
    locus = build(:locus, lat: 50.51, lon: nil)
    result = latlon_link(locus)
    assert_equal "50.5100", result
    assert_not_includes result, "<a"
  end

  test "google_maps_link renders a globe icon linking to Google Maps in a new tab" do
    locus = build(:locus, lat: 50.51, lon: 30.79)
    html = google_maps_link(locus)
    assert_includes html, %(href="https://www.google.com/maps?q=50.51,30.79")
    assert_includes html, %(target="_blank")
    assert_includes html, "fa-globe"
    assert_includes html, %(class="maps-icon")
    assert_includes html, %(title="50.5100;30.7900")
  end

  test "google_maps_link returns nil when coordinates are incomplete" do
    assert_nil google_maps_link(build(:locus, lat: 50.51, lon: nil))
    assert_nil google_maps_link(build(:locus, lat: nil, lon: nil))
  end
end
