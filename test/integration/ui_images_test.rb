require 'test_helper'
require 'capybara_helper'

class UIImagesTest < ActionDispatch::IntegrationTest

  include JavaScriptTestCase

  test "Save existing image with no changes" do
    img = Factory.create(:image)
    
    login_as_admin
    visit edit_image_path(img)

    lambda { click_button('Save'); sleep 0.5 }.should_not change(Image, :count)
    current_path.should == show_image_path(img.to_url_params)
  end

 test "Adding new image" do
    login_as_admin
    visit new_image_path

    fill_in('Code', :with => 'test-img-capybara')
    fill_in('Title', :with => 'Capybara test image')

    within('.observations_search') do
      fill_in('Date', :with => '2008-07-01')
      select_suggestion('Brovary', :from => 'Location')
    end

    lambda { click_button('Save'); sleep 0.5 }.should change(Image, :count).by(1)
    img = Image.find_by_code('test-img-capybara')
    current_path.should == show_image_path(img.to_url_params)
  end

end