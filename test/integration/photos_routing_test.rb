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

  test "legacy country urls redirect to photo galleries" do
    get "/usa"
    assert_redirected_to "/photos/usa"

    get "/en/united_kingdom"
    assert_redirected_to "/en/photos/united_kingdom"
  end
end
