# frozen_string_literal: true

require "test_helper"
require "capybara_helper"

class PhotosRoutingTest < ActionDispatch::IntegrationTest
  include CapybaraTestCase

  # This test checks that the English photos feed does not redirect to the English home page
  # Roting test for some reason does not work correctly in this case.
  test "English photos feed is rendered correctly" do
    visit "/en/photos.xml"
    assert_current_path "/en/photos.xml"
  end

  test "Russian photos feed is rendered correctly" do
    visit "/ru/photos.xml"
    assert_current_path "/ru/photos.xml"
  end

  test "English photos page is redirected to EN root" do
    visit "/en/photos"
    assert_current_path "/en"
  end
end
