# frozen_string_literal: true

require "application_system_test_case"

class JSMapTest < ApplicationSystemTestCase

  test "Ajax observation search works on map edit" do
    create(:observation, card: create(:card, observ_date: "2011-01-01"))
    card2 = create(:card, observ_date: "2011-01-02")
    create(:observation, card: card2)
    create(:observation, card: card2)
    login_as_admin
    visit edit_map_path
    fill_in_date("Date", "2011-01-02")
    click_button("Search")
    assert_css ".obs-list li"
    assert_equal 2, all(".obs-list li").size
  end

end
