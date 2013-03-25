require 'test_helper'
require 'capybara_helper'

class UICommentsTest < ActionDispatch::IntegrationTest

  include JavaScriptTestCase

  test "Reply to comment (JS form)" do
    comment = create(:comment)
    blogpost = comment.post
    visit show_post_path(blogpost.to_url_params)
    first('.reply a').click
    within("form#reply#{comment.id}") do
      fill_in(Comment.negative_captcha, with: 'Vasya')
      fill_in('comment_text', with: 'Some text')
      click_button("save_button")
    end

    assert_equal show_post_path(blogpost.to_url_params), current_path
    assert page.has_content?("Vasya")
    assert_equal 1, comment.subcomments.size
  end

end
