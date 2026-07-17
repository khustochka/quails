# frozen_string_literal: true

require "test_helper"

class PlaceholderCountryTest < ActiveSupport::TestCase
  test "hardcoded? is true for a country with a lifelist title" do
    assert PlaceholderCountry.hardcoded?("canada")
  end

  test "hardcoded? is false for a slug without a lifelist title" do
    assert_not PlaceholderCountry.hardcoded?("sumy_obl")
  end

  test "name falls back to the localized lifelist title phrase" do
    I18n.with_locale(:en) do
      assert_equal "Canada List", PlaceholderCountry.new("canada").name
    end
  end

  test "subregion_ids is empty so it never matches any card" do
    assert_empty PlaceholderCountry.new("canada").subregion_ids
  end

  test "checklist is empty and groups by taxonomy without yielding" do
    checklist = PlaceholderCountry.new("ukraine").checklist
    assert_empty checklist
    yielded = false
    checklist.group_by_taxonomy { yielded = true }
    assert_not yielded
  end
end
