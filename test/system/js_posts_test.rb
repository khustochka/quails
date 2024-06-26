# frozen_string_literal: true

require "application_system_test_case"

class JSPostsTest < ApplicationSystemTestCase
  test "Visit new post page" do
    login_as_admin
    visit new_post_path
    assert_predicate find(:xpath, "//h1[text()='New post']"), :present?
  end
end
