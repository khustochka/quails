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

  test "Adding new image" do
    FactoryGirl.create(:observation, :observ_date => '2008-07-01')
    login_as_admin
    visit new_image_path
    
    fill_in('Code', :with => 'test-img-capybara')
    fill_in('Title', :with => 'Capybara test image')
    
    within('.observation_search') do
      fill_in('Date', :with => '2008-07-01')
      select_suggestion('Brovary', :from => 'Location')
      click_button 'Search'
    end
        
    find(:xpath, "//ul[contains(@class,'found-obs')]/li[1]").drag_to find('.observation_list')
    
    lambda { click_button('Save') }.should change(Image, :count).by(1)
    img = Image.find_by_code('test-img-capybara')
    current_path.should == show_image_path(img.to_url_params)
  end

  test "Image save should not use all found observations" do
    FactoryGirl.create(:observation, :species => seed(:merser))
    FactoryGirl.create(:observation, :species => seed(:anapla))
    login_as_admin
    visit new_image_path
    
    fill_in('Code', :with => 'test-img-capybara')
    fill_in('Title', :with => 'Capybara test image')
    
    within('.observation_search') do
      fill_in('Date', :with => '')
      click_button 'Search'
    end
        
    find(:xpath, "//ul[contains(@class,'found-obs')]/li[div/span[contains(text(),'Mergus serrator')]]").drag_to find('.observation_list')
    
    lambda { click_button('Save') }.should change(Image, :count).by(1)
    img = Image.find_by_code('test-img-capybara')
    
    img.species.map(&:name_sci).should == ['Mergus serrator']
  end

  test "Remove an observation from image" do
    img = FactoryGirl.create(:image)
    FactoryGirl.create(:observation, :species => seed(:lancol), :images => [img])
    FactoryGirl.create(:observation, :species => seed(:denmaj), :images => [img])

    login_as_admin
    visit edit_image_path(img)
    within(:xpath, "//ul[contains(@class,'current-obs')]/li[2]") do
      find('.remove').click
    end

    click_button('Save')
    img.reload
    img.observations.size.should == 2
  end

end