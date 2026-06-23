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
end
