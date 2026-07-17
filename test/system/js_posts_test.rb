# frozen_string_literal: true

require "application_system_test_case"

class JSPostsTest < ApplicationSystemTestCase
  test "Attach card to the post core" do
    create(:card, observ_date: "2010-06-18")

    p = create(:post)

    login_as_admin
    visit edit_post_core_path(p.post_core)
    fill_in_date("Date:", "2010-06-18")

    click_button("Search")

    assert_css "li.observ_card"

    accept_confirm do
      page.find("li.observ_card").click_link("Attach to this post")
    end

    assert_no_css ".loading"
    assert_current_path edit_post_core_path(p.post_core)
    assert_css "li.observ_card a", text: "Detach from this post"

    assert_equal 1, p.reload.cards.size
  end

  test "Detach card from post core edit page updates UI without reloading" do
    post = create(:post)
    card = create(:card, post_core: post.post_core)

    login_as_admin
    visit edit_post_core_path(post.post_core)

    assert_css "li.observ_card"

    accept_confirm do
      find("li.observ_card").click_link("Detach from this post")
    end

    assert_current_path edit_post_core_path(post.post_core)
    assert_no_css "[data-attached-list] li.observ_card"
    assert_nil card.reload.post_core_id
  end
end
