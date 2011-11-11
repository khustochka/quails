require 'test_helper'
require 'capybara_helper'

class UIObservationsAddTest < ActionDispatch::IntegrationTest

  include JavaScriptTestCase

  test "Adding new rows to observations bulk form" do
    login_as_admin
    visit add_observations_path
    all('.obs-row').size.should == 0

    find(:xpath, "//span[text()='Add new row']").click
    all('.obs-row').size.should == 1

    find(:xpath, "//span[text()='Add new row']").click
    all('.obs-row').size.should == 2
  end

  # NO JavaScript test
  test 'Adding one observation if JavaScript is off' do
    Capybara.use_default_driver
    login_as_admin
    visit add_observations_path
    all('.obs-row').size.should == 1
    select('Brovary', :from => 'Location')
    fill_in('Date', :with => '2011-04-08')
    select('Cyanistes caeruleus', :from => 'Species')
    lambda { click_button('Save') }.should change(Observation, :count).by(1)
  end

  test 'Species autosuggest box should have Avis incognita and be able to add it' do
    login_as_admin
    visit add_observations_path
    find(:xpath, "//span[text()='Add new row']").click
    select_suggestion('Brovary', :from => 'Location')
    fill_in('Date', :with => '2011-04-08')
    select_suggestion('- Avis incognita', :from => 'Species')
    lambda { click_button('Save') }.should change(Observation, :count).by(1)
    Observation.order('id DESC').limit(1).first.species_id.should == 0
  end

  test "Adding several observations" do
    login_as_admin
    visit add_observations_path

    select_suggestion('Brovary', :from => 'Location')
    fill_in('Date', :with => '2011-04-09')

    find(:xpath, "//span[text()='Add new row']").click
    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Crex crex', :from => 'Species')
    end

    within(:xpath, "//div[contains(@class,'obs-row')][2]") do
      select_suggestion('Falco tinnunculus', :from => 'Species')
    end

    lambda { click_button('Save') }.should change(Observation, :count).by(2)
    page.should have_css('.obs-row.has-id.save-success')
    
  end

  test "Adding observations for the post" do
    blogpost = FactoryGirl.create(:post)
    login_as_admin

    visit show_post_path(blogpost.to_url_params)
    click_link 'Add more observations'

    page.should have_css('label a', :text => blogpost.title)

    select_suggestion('Brovary', :from => 'Location')
    fill_in('Date', :with => '2011-04-09')

    find(:xpath, "//span[text()='Add new row']").click
    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Crex crex', :from => 'Species')
    end

    within(:xpath, "//div[contains(@class,'obs-row')][2]") do
      select_suggestion('Falco tinnunculus', :from => 'Species')
    end

    lambda { click_button('Save') }.should change(Observation, :count).by(2)
    page.should have_css('.obs-row.has-id.save-success')

    blogpost.observations.size.should == 2
  end

end
