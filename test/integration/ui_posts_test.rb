# frozen_string_literal: true

require "test_helper"
require "capybara_helper"

class UIPostsTest < ActionDispatch::IntegrationTest

  include CapybaraTestCase

  test "Adding post" do
    login_as_admin
    visit new_post_path
    fill_in("Slug", with: "new-post")
    fill_in("Title", with: "Test post")
    fill_in("post_body", with: "Post text.")
    select("OPEN", from: "Status")
    select("OBSR", from: "Topic")
    click_button("Save")
    blogpost = Post.find_by(slug: "new-post")
    assert_current_path show_post_path(blogpost.to_url_params)
  end

  test "Editing post" do
    blogpost = create(:post)
    login_as_admin
    visit edit_post_path(blogpost)
    fill_in("Slug", with: "changed-post")
    fill_in("Title", with: "Test post edited")
    fill_in("post_body", with: "Post text edited.")
    fill_in("Post date", with: "2009-07-27")
    click_button("Save")
    blogpost = Post.find_by(slug: "changed-post")
    assert_current_path show_post_path(blogpost.to_url_params)
  end

  test "Navigation via Edit this and Show this links" do
    blogpost = create(:post)
    login_as_admin
    visit show_post_path(blogpost.to_url_params)
    click_link("Edit this one")
    assert_current_path edit_post_path(blogpost)
    click_link("Show this one")
    assert_current_path show_post_path(blogpost.to_url_params)
  end

  test "Add comment to post (no JS)" do
    ActionController::Base.allow_forgery_protection = true

    blogpost = create(:post)
    visit show_post_path(blogpost.to_url_params)
    within("form#new_comment") do
      fill_in(CommentsHelper::REAL_NAME_FIELD, with: "Vasya")
      fill_in("comment_body", with: "Some text")
    end
    assert_difference "Comment.count", 1 do
      click_button("save_button")
    end

    assert_css "h6.name", text: "Vasya"
  end

  # In case the test fails
  teardown do
    ActionController::Base.allow_forgery_protection = false
  end

  test "Add reply to comment (no JS)" do
    ActionController::Base.allow_forgery_protection = true

    comment = create(:comment)
    blogpost = comment.post
    visit show_post_path(blogpost.to_url_params)
    first(".reply a").click
    within("form#new_comment") do
      fill_in(CommentsHelper::REAL_NAME_FIELD, with: "Vasya")
      fill_in("comment_body", with: "Some text")
    end
    click_button("save_button")

    assert_current_path show_post_path(blogpost.to_url_params)
    assert_css "h6.name", text: "Vasya"
    assert_equal 1, comment.subcomments.size
  end

  test "Try to post invalid comment (no JS)" do
    blogpost = create(:post)
    visit show_post_path(blogpost.to_url_params)
    within("form#new_comment") do
      #fill_in('comment_name', with: 'Vasya')
      fill_in("comment_body", with: "Some text")
    end
    click_button("save_button")

    assert_current_path comments_path
    assert_equal "Some text", find("#comment_body").value
  end

  test "Try to post invalid reply to comment (no JS)" do
    comment = create(:comment)
    blogpost = comment.post
    visit show_post_path(blogpost.to_url_params)
    first(".reply a").click
    within("form#new_comment") do
      #fill_in('comment_name', with: 'Vasya')
      fill_in("comment_body", with: "Some text")
    end
    click_button("save_button")

    assert_current_path comments_path
    assert_equal "Some text", find("#comment_body").value
  end

  test "Screened comment should show a message (no JS)" do
    blogpost = create(:post)
    visit show_post_path(blogpost.to_url_params)
    within("form#new_comment") do
      fill_in(CommentsHelper::REAL_NAME_FIELD, with: "Vasya")
      fill_in("comment_body", with: "Cialis")
    end
    assert_difference "Comment.count", 1 do
      click_button("save_button")
    end

    comment = Comment.last

    assert_selector "p.comment_screened#comment#{comment.id}"
  end

end
