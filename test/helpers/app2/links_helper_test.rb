# frozen_string_literal: true

require "test_helper"

class App2::LinksHelperTest < ActionView::TestCase
  include App2::LinksHelper

  test "marks the link as external and opens it in a new tab" do
    result = external_link("eBird", "https://ebird.org/")

    assert_dom_equal %(<a class="external" rel="nofollow" target="_blank" href="https://ebird.org/">eBird</a>), result
  end

  test "keeps a given string class and adds the external one" do
    result = external_link("eBird", "https://ebird.org/", class: "button")

    assert_includes result, %(class="button external")
  end

  test "keeps given array classes and adds the external one" do
    result = external_link("eBird", "https://ebird.org/", class: %w(button wide))

    assert_includes result, %(class="button wide external")
  end

  test "does not modify the class passed in by the caller" do
    classes = ["button"]

    external_link("eBird", "https://ebird.org/", class: classes)

    assert_equal ["button"], classes
  end

  test "nofollow can be turned off" do
    result = external_link("eBird", "https://ebird.org/", nofollow: false)

    assert_not_includes result, "nofollow"
    assert_includes result, %(target="_blank")
  end

  test "the nofollow option is not rendered as an attribute" do
    result = external_link("eBird", "https://ebird.org/", nofollow: true)

    assert_includes result, %(rel="nofollow")
    assert_not_includes result, %(nofollow="true")
  end

  test "target can be overridden" do
    result = external_link("eBird", "https://ebird.org/", target: "_self")

    assert_includes result, %(target="_self")
  end
end
