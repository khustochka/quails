# frozen_string_literal: true

require "application_system_test_case"

class JSCommentsTest < ApplicationSystemTestCase

  test "Add comment to post (JS form)" do
    # No way to check that ajax request was sent...
    blogpost = create(:post)
    visit show_post_path(blogpost.to_url_params)
    within("form#new_comment") do
      fill_in(CommentsHelper::REAL_NAME_FIELD, with: 'Vasya')
      fill_in('comment_text', with: 'Some text')
      assert_difference "Comment.count", 1 do
        click_button("save_button")
        assert_css "#save_button:not([disabled])"
      end
    end
    assert_css "h6.name", text: "Vasya"

  end

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
    assert_css "h6.name", text: "Vasya"
    assert_equal 1, comment.subcomments.size
  end

  test "Reply from reply page - JS on" do
    comment = create(:comment)
    blogpost = comment.post
    visit reply_comment_path(comment)
    within("form#new_comment") do
      fill_in(CommentsHelper::REAL_NAME_FIELD, with: 'Vasya')
      fill_in('comment_text', with: 'Some text')
      click_button("save_button")
    end

    assert_current_path show_post_path(blogpost.to_url_params)
    assert_css "h6.name", text: "Vasya"
    assert_equal 1, comment.subcomments.size
  end

end
