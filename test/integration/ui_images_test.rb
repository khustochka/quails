require 'test_helper'
require 'test/capybara_helper'

class UIImagesTest < ActionDispatch::IntegrationTest

  include JavaScriptTestCase

  test "Adding new image" do
    login_as_admin
    visit new_image_path

    fill_in('Code', :with => 'test-img-capybara')
    fill_in('Title', :with => 'Capybara test image')

    within('.observations_search') do
      fill_in('Date', :with => '2008-07-01')
      select_suggestion('Brovary', :from => 'Location')
    end

    lambda { click_button('Save') }.should change(Image, :count).by(1)
    img = Post.find_by_code('test-img-capybara')
    current_path.should == image_path(img)
  end

end