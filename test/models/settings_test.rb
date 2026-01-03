# frozen_string_literal: true

require "test_helper"

class SettingsTest < ActiveSupport::TestCase
  test "current_year returns correct value if set" do
    Settings.create(key: "current_year", value: "2023")
    assert_equal 2023, Settings.current_year
  end

  test "current_year returns license year if set to empty string" do
    Settings.create(key: "current_year", value: "")
    assert_equal Quails::LICENSE_YEAR, Settings.current_year
  end

  test "current_year returns license year if not set" do
    Settings.where(key: "current_year").delete_all
    assert_equal Quails::LICENSE_YEAR, Settings.current_year
  end
end
