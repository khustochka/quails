# frozen_string_literal: true

require "test_helper"
require "capybara_helper"

class PhotosRoutingTest < ActionDispatch::IntegrationTest
  include CapybaraTestCase

  # This test checks that the English photos feed does not redirect to the English home page.
  # The regular routing asserts (as in test/integration/routing.rb) do not recognize redirects.
  test "English photos feed is rendered correctly" do
    visit "/en/photos.xml"
    assert_current_path "/en/photos.xml"
  end

  test "Russian photos feed is rendered correctly" do
    visit "/ru/photos.xml"
    assert_current_path "/ru/photos.xml"
  end
end
