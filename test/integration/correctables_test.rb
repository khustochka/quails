# frozen_string_literal: true

require "test_helper"
require "capybara_helper"

class CorrectablesTest < ActionDispatch::IntegrationTest
  include CapybaraTestCase

  setup do
    @correction = create(:correction)
    @post1 = create(:post, body: "Link http://google.com", face_date: "2022-08-02")
    @post2 = create(:post, body: "Link https://google.com", face_date: "2022-08-01")
    @post3 = create(:post, body: "Link http://flickr.com", face_date: "2022-07-29")
  end

  test "when submitted with Save it saves and returns to the same edit form" do
    login_as_admin
    visit edit_post_path(@post3, correction: @correction.id)
    fill_in("Title", with: "Test post edited")
    click_button("Save")
    assert_current_path edit_post_path(@post3, correction: @correction.id)
    @post3.reload
    assert_equal "Test post edited", @post3.title
  end

  test "when submitted with Skip it redirects to the next record" do
    login_as_admin
    visit edit_post_path(@post3, correction: @correction.id)
    fill_in("Title", with: "Test post edited")
    click_button("Skip")
    assert_current_path edit_post_path(@post1, correction: @correction.id)
    @post3.reload
    assert_not_equal "Test post edited", @post3.title
  end

  test "when submitted with Save and next it saves and redirects to the next record" do
    login_as_admin
    visit edit_post_path(@post3, correction: @correction.id)
    fill_in("Title", with: "Test post edited")
    click_button("Save and next >>")
    assert_current_path edit_post_path(@post1, correction: @correction.id)
    @post3.reload
    assert_equal "Test post edited", @post3.title
  end
end
