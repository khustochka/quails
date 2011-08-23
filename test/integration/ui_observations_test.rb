require 'test_helper'
require 'test/capybara_helper'

class UIObservationsTest < ActionDispatch::IntegrationTest

  include JavaScriptTestCase

  test "Adding new rows to observations bulk form" do
    login_as_admin
    visit new_observation_path
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
    visit new_observation_path
    all('.obs-row').size.should == 1
    select('Brovary', :from => 'Location')
    fill_in('Date', :with => '2011-04-08')
    select('Parus caeruleus', :from => 'Species')
    lambda { click_button('Save') }.should change(Observation, :count).by(1)
  end

  test "Adding several observations" do
    login_as_admin
    visit new_observation_path

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
  end

end