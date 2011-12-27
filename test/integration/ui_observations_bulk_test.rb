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
    select 'park', :from => 'Biotope'
    lambda { submit_form_with('Save') }.should change(Observation, :count).by(1)
  end

  test 'Species autosuggest box should have Avis incognita and be able to add it' do
    login_as_admin
    visit add_observations_path
    find(:xpath, "//span[text()='Add new row']").click
    select_suggestion('Brovary', :from => 'Location')
    fill_in('Date', :with => '2011-04-08')
    select_suggestion('- Avis incognita', :from => 'Species')
    select_suggestion 'park', :from => 'Biotope'
    lambda { submit_form_with('Save') }.should change(Observation, :count).by(1)
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
      select_suggestion 'park', :from => 'Biotope'
    end

    within(:xpath, "//div[contains(@class,'obs-row')][2]") do
      select_suggestion('Falco tinnunculus', :from => 'Species')
      select_suggestion 'park', :from => 'Biotope'
    end

    lambda { submit_form_with('Save') }.should change(Observation, :count).by(2)
    page.should have_css('.obs-row.save-success')

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
      select_suggestion 'park', :from => 'Biotope'
    end

    within(:xpath, "//div[contains(@class,'obs-row')][2]") do
      select_suggestion('Falco tinnunculus', :from => 'Species')
      select_suggestion 'park', :from => 'Biotope'
    end

    lambda { submit_form_with('Save') }.should change(Observation, :count).by(2)
    page.should have_css('.obs-row.save-success')

    blogpost.observations.size.should == 2
  end

  test "Start adding observations for post but then uncheck it" do
    blogpost = FactoryGirl.create(:post)
    login_as_admin

    visit show_post_path(blogpost.to_url_params)
    click_link 'Add more observations'

    page.should have_css('label a', :text => blogpost.title)

    select_suggestion('Brovary', :from => 'Location')
    fill_in('Date', :with => '2011-04-09')
    uncheck('observation_post_id')

    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Crex crex', :from => 'Species')
      select_suggestion 'park', :from => 'Biotope'
    end

    submit_form_with('Save')
    page.should have_css('.obs-row.save-success')

    blogpost.observations.size.should == 0
  end

  test "Add observations for post, then save unlinked" do
    blogpost = FactoryGirl.create(:post)
    login_as_admin

    visit show_post_path(blogpost.to_url_params)
    click_link 'Add more observations'

    page.should have_css('label a', :text => blogpost.title)

    select_suggestion('Brovary', :from => 'Location')
    fill_in('Date', :with => '2011-04-09')

    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Crex crex', :from => 'Species')
      select_suggestion 'park', :from => 'Biotope'
    end

    submit_form_with('Save')
    page.should have_css('.obs-row.save-success')

    blogpost.observations.size.should == 1
    obs = blogpost.observations.first

    uncheck('observation_post_id')
    submit_form_with('Save')

    blogpost.observations.reload.size.should == 0
    obs.reload.post_id.should be_nil
  end

  test "Add and update observations" do
    login_as_admin
    visit add_observations_path

    select_suggestion('Brovary', :from => 'Location')
    fill_in('Date', :with => '2011-04-09')

    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Crex crex', :from => 'Species')
      select_suggestion 'park', :from => 'Biotope'
    end

    lambda { submit_form_with('Save') }.should change(Observation, :count).by(1)
    page.should have_css('.obs-row.save-success')

    find(:xpath, "//span[text()='Add new row']").click

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Dryocopus martius', :from => 'Species')
    end

    within(:xpath, "//div[contains(@class,'obs-row')][2]") do
      select_suggestion('Falco tinnunculus', :from => 'Species')
      select_suggestion 'park', :from => 'Biotope'
    end

    lambda { submit_form_with('Save') }.should change(Observation, :count).by(1)

    Species.find_by_code('drymar').observations.should_not be_empty
    Species.find_by_code('faltin').observations.should_not be_empty
    Species.find_by_code('crecre').observations.should be_empty

  end

  test "Bulk edit page" do
    FactoryGirl.create(:observation, :species => seed(:melgal), :observ_date => "2010-06-18")
    FactoryGirl.create(:observation, :species => seed(:anapla), :observ_date => "2010-06-18")
    login_as_admin
    visit bulk_observations_path(:observ_date => "2010-06-18", :locus_id => seed(:brovary).id, :mine => true)

    all('.obs-row').size.should == 2

    [1, 2].map do |i|
      find(:xpath, "//div[contains(@class,'obs-row')][#{i}]//input[contains(@class, 'ui-autocomplete-input')]").value
    end.should =~ ['Anas platyrhynchos', 'Meleagris gallopavo']
  end

  test "Bulk edit functionality" do
    FactoryGirl.create(:observation, :species => seed(:melgal), :observ_date => "2010-06-18")
    FactoryGirl.create(:observation, :species => seed(:anapla), :observ_date => "2010-06-18")
    login_as_admin
    visit bulk_observations_path(:observ_date => "2010-06-18", :locus_id => seed(:brovary).id, :mine => true)

    within(:xpath, "//div[contains(@class,'obs-row')][1]") do
      select_suggestion('Dryocopus martius', :from => 'Species')
    end

    lambda { submit_form_with('Save') }.should change(Observation, :count).by(0)

    Species.find_by_code('drymar').observations.should_not be_empty
  end

  test "Bulk edit preserves post" do
    blogpost = FactoryGirl.create(:post)
    obs1 = FactoryGirl.create(:observation, :species => seed(:melgal), :observ_date => "2010-06-18", :post_id => blogpost.id)
    obs2 = FactoryGirl.create(:observation, :species => seed(:anapla), :observ_date => "2010-06-18")
    login_as_admin
    visit bulk_observations_path(:observ_date => "2010-06-18", :locus_id => seed(:brovary).id, :mine => true)

    lambda { submit_form_with('Save') }.should change(Observation, :count).by(0)

    obs1.reload.post_id.should == blogpost.id
    obs2.reload.post_id.should be_nil
  end

end
