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
      fill_in('comment_name', with: 'Vasya')
      fill_in('comment_text', with: 'Some text')
      click_button("save_button")
    end

    expect(current_path).to eq(show_post_path(blogpost.to_url_params))
    expect(page).to have_content("Vasya")
    expect(comment.subcomments.size).to eq(1)
  end

end
