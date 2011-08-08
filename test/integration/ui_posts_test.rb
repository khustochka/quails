require "capybara_test_helper"

class UIPostsTest < QuailsTestCase::CapybaraTestCase

  setup do
    @blogpost = Factory.create(:post)
  end

  test "Adding post" do
    login_as_admin

    visit show_post_path(@blogpost.to_url_params)

  end
end