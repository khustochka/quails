require 'test_helper'
require 'capybara_helper'

class UIImagesTest < ActionDispatch::IntegrationTest

  include JavaScriptTestCase

  test "Save existing image with no changes" do
    img = FactoryGirl.create(:image)
    FactoryGirl.create(:observation, :species => seed(:lancol), :images => [img])
    
    login_as_admin
    visit edit_image_path(img)

    lambda { click_button('Save') }.should_not change(Image, :count)
    current_path.should == show_image_path(img.to_url_params)
    img.reload
    img.observations.size.should == 2
  end

  test "Remove an observation" do
    img = FactoryGirl.create(:image)
    FactoryGirl.create(:observation, :species => seed(:lancol), :images => [img])
    FactoryGirl.create(:observation, :species => seed(:denmaj), :images => [img])
    
    login_as_admin
    visit edit_image_path(img)
    within(:xpath, "//ul[contains(@class,'obs-list')]/li[2]") do
      find('.remove').click
    end
    
    click_button('Save')
    img.reload
    img.observations.size.should == 2
  end

  test "Removing all observations prevents from saving" do
    img = FactoryGirl.create(:image)
    
    login_as_admin
    visit edit_image_path(img)
    within(:xpath, "//ul[contains(@class,'obs-list')]/li[1]") do
      find('.remove').click
    end
    
    click_button('Save')
    current_path.should_not == show_image_path(img.to_url_params)
    
    find('ul.obs-list li').should have_content(img.species[0].name_sci)
  end

 # test "Adding new image" do
    # login_as_admin
    # visit new_image_path
# 
    # fill_in('Code', :with => 'test-img-capybara')
    # fill_in('Title', :with => 'Capybara test image')
# 
    # within('.observations_search') do
      # fill_in('Date', :with => '2008-07-01')
      # select_suggestion('Brovary', :from => 'Location')
    # end
# 
    # lambda { click_button('Save') }.should change(Image, :count).by(1)
    # img = Image.find_by_code('test-img-capybara')
    # current_path.should == show_image_path(img.to_url_params)
  # end

end