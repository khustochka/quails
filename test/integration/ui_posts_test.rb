require 'test_helper'
require 'capybara_helper'

class UIPostsTest < ActionDispatch::IntegrationTest

  include CapybaraTestCase

  test "Adding post" do
    login_as_admin
    visit new_post_path
    fill_in('Code', with: 'new-post')
    fill_in('Title', with: 'Test post')
    fill_in('Text', with: 'Post text.')
    select('OPEN', from: 'Status')
    select('OBSR', from: 'Topic')
    click_button('Save')
    blogpost = Post.find_by_code('new-post')
    current_path.should == show_post_path(blogpost.to_url_params)
  end

  test "Editing post" do
    blogpost = create(:post)
    login_as_admin
    visit edit_post_path(blogpost)
    fill_in('Code', with: 'changed-post')
    fill_in('Title', with: 'Test post edited')
    fill_in('Text', with: 'Post text edited.')
    fill_in('Post date', with: '2009-07-27')
    click_button('Save')
    blogpost = Post.find_by_code('changed-post')
    current_path.should == show_post_path(blogpost.to_url_params)
  end

  test "Navigation via Edit this and Show this links" do
    blogpost = create(:post)
    login_as_admin
    visit show_post_path(blogpost.to_url_params)
    click_link('Edit this one')
    current_path.should == edit_post_path(blogpost)
    click_link('Show this one')
    current_path.should == show_post_path(blogpost.to_url_params)
  end

  test "Add comment to post" do
    blogpost = create(:post)
    visit show_post_path(blogpost.to_url_params)
    within("form#new_comment") do
      fill_in('comment_name', with: 'Vasya')
      fill_in('comment_text', with: 'Some text')
    end
    click_button("save_button")

    page.should have_content("Vasya")

  end

  test "Add reply to comment (no JS)" do
    comment = create(:comment)
    blogpost = comment.post
    visit show_post_path(blogpost.to_url_params)
    first('.reply a').click
    within("form#new_comment") do
      fill_in('comment_name', with: 'Vasya')
      fill_in('comment_text', with: 'Some text')
    end
    click_button("save_button")

    current_path.should == show_post_path(blogpost.to_url_params)
    page.should have_content("Vasya")
    comment.subcomments.size.should == 1
  end

  test "Try to post invalid comment (no JS)" do
    blogpost = create(:post)
    visit show_post_path(blogpost.to_url_params)
    within("form#new_comment") do
      #fill_in('comment_name', with: 'Vasya')
      fill_in('comment_text', with: 'Some text')
    end
    click_button("save_button")

    current_path.should == comments_path
    find('#comment_text').text.should == 'Some text'
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

    current_path.should == comments_path
    find('#comment_text').text.should == 'Some text'
  end

end