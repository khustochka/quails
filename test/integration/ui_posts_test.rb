require "capybara_test_helper"

class UIPostsTest < CapybaraTestCase

  setup do
    @blogpost = Factory.create(:post)
  end

  test "Adding post" do
    login_as_admin

    visit new_post_path

    fill_in('Code', :with => 'new-post')
    fill_in('Title', :with => 'Test post')
    fill_in('Text', :with => 'Post text.')
    select('OPEN', :from => 'Status')
    select('OBSR', :from => 'Topic')

  end
end