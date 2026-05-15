# frozen_string_literal: true

require "application_system_test_case"

class JSPostsTest < ApplicationSystemTestCase
  test "Visit new post core page" do
    login_as_admin
    visit new_post_core_path
    assert_predicate find(:xpath, "//h1[text()='New post core']"), :present?
  end

  test "Detach card from post show page updates UI without reloading" do
    post = create(:post)
    card = create(:card, post_core: post.post_core)

    login_as_admin
    visit show_post_path(post.to_url_params)

    assert_css "li.observ_card"

    accept_confirm do
      find("li.observ_card").click_link("Detach from this post")
    end

    assert_current_path show_post_path(post.to_url_params)
    assert_no_css "li.observ_card"
    assert_nil card.reload.post_core_id
  end
end
