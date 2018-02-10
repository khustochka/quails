require 'test_helper'
require 'capybara_helper'

class JSCommentsTest < ActionDispatch::IntegrationTest

  include JavaScriptTestCase

  test "Reply to comment (JS form)" do
    comment = create(:comment)
    blogpost = comment.post
    visit show_post_path(blogpost.to_url_params)
    first('.reply a').click
    within("form#reply#{comment.id}") do
      fill_in(CommentsHelper::REAL_NAME_FIELD, with: 'Vasya')
      fill_in('comment_text', with: 'Some text')
      click_button("save_button")
    end

    assert_current_path show_post_path(blogpost.to_url_params)
    assert_content "Vasya"
    assert_equal 1, comment.subcomments.size
  end

  test "Reply from reply page (JS on)" do
    comment = create(:comment)
    blogpost = comment.post
    visit reply_comment_path(comment)
    within("form#new_comment") do
      fill_in(CommentsHelper::REAL_NAME_FIELD, with: 'Vasya')
      fill_in('comment_text', with: 'Some text')
      click_button("save_button")
    end

    assert_current_path show_post_path(blogpost.to_url_params)
    assert_content "Vasya"
    assert_equal 1, comment.subcomments.size
  end

end
