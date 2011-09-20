require 'test_helper'
require 'test/capybara_helper'

class UIPostsTest < ActionDispatch::IntegrationTest

  include CapybaraTestCase

  test "Adding post" do
    login_as_admin
    visit new_post_path
    fill_in('Code', :with => 'new-post')
    fill_in('Title', :with => 'Test post')
    fill_in('Text', :with => 'Post text.')
    select('OPEN', :from => 'Status')
    select('OBSR', :from => 'Topic')
    click_button('Save')
    blogpost = Post.find_by_code('new-post')
    current_path.should == show_post_path(blogpost.to_url_params)
  end

  test "Editing post" do
    blogpost = FactoryGirl.create(:post)
    login_as_admin
    visit edit_post_path(blogpost)
    fill_in('Code', :with => 'changed-post')
    fill_in('Title', :with => 'Test post edited')
    fill_in('Text', :with => 'Post text edited.')
    fill_in('Post date', :with => '2009-07-27')
    click_button('Save')
    blogpost = Post.find_by_code('changed-post')
    current_path.should == show_post_path(blogpost.to_url_params)
  end

  test "Navigation via Edit this and Show this links" do
    blogpost = FactoryGirl.create(:post)
    login_as_admin
    visit show_post_path(blogpost.to_url_params)
    click_link('Edit this one')
    current_path.should == edit_post_path(blogpost)
    click_link('Show this one')
    current_path.should == show_post_path(blogpost.to_url_params)
  end

end