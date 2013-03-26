require 'test_helper'
require 'capybara_helper'

class UIPostsTest < ActionDispatch::IntegrationTest

  include CapybaraTestCase

  test "Adding post" do
    login_as_admin
    visit new_post_path
    fill_in('Slug', with: 'new-post')
    fill_in('Title', with: 'Test post')
    fill_in('post_text', with: 'Post text.')
    select('OPEN', from: 'Status')
    select('OBSR', from: 'Topic')
    click_button('Save')
    blogpost = Post.find_by_slug('new-post')
    assert_equal show_post_path(blogpost.to_url_params), current_path
  end

  test "Editing post" do
    blogpost = create(:post)
    login_as_admin
    visit edit_post_path(blogpost)
    fill_in('Slug', with: 'changed-post')
    fill_in('Title', with: 'Test post edited')
    fill_in('post_text', with: 'Post text edited.')
    fill_in('Post date', with: '2009-07-27')
    click_button('Save')
    blogpost = Post.find_by_slug('changed-post')
    assert_equal show_post_path(blogpost.to_url_params), current_path
  end

  test "Navigation via Edit this and Show this links" do
    blogpost = create(:post)
    login_as_admin
    visit show_post_path(blogpost.to_url_params)
    click_link('Edit this one')
    assert_equal edit_post_path(blogpost), current_path
    click_link('Show this one')
    assert_equal show_post_path(blogpost.to_url_params), current_path
  end

  test "Add comment to post" do
    blogpost = create(:post)
    visit show_post_path(blogpost.to_url_params)
    within("form#new_comment") do
      fill_in($negative_captcha, with: 'Vasya')
      fill_in('comment_text', with: 'Some text')
    end
    click_button("save_button")

    assert page.has_content?("Vasya")

  end

  test "Add reply to comment (no JS)" do
    comment = create(:comment)
    blogpost = comment.post
    visit show_post_path(blogpost.to_url_params)
    first('.reply a').click
    within("form#new_comment") do
      fill_in($negative_captcha, with: 'Vasya')
      fill_in('comment_text', with: 'Some text')
    end
    click_button("save_button")

    assert_equal show_post_path(blogpost.to_url_params), current_path
    assert page.has_content?("Vasya")
    assert_equal 1, comment.subcomments.size
  end

  test "Try to post invalid comment (no JS)" do
    blogpost = create(:post)
    visit show_post_path(blogpost.to_url_params)
    within("form#new_comment") do
      #fill_in('comment_name', with: 'Vasya')
      fill_in('comment_text', with: 'Some text')
    end
    click_button("save_button")

    assert_equal comments_path, current_path
    assert_equal 'Some text', find('#comment_text').value
  end

  test "Try to post invalid reply to comment (no JS)" do
    comment = create(:comment)
    blogpost = comment.post
    visit show_post_path(blogpost.to_url_params)
    first('.reply a').click
    within("form#new_comment") do
      #fill_in('comment_name', with: 'Vasya')
      fill_in('comment_text', with: 'Some text')
    end
    click_button("save_button")

    assert_equal comments_path, current_path
    assert_equal 'Some text', find('#comment_text').value
  end

end
