require 'test_helper'
require 'capybara_helper'

class UIObservationsTest < ActionDispatch::IntegrationTest

  include CapybaraTestCase

  test 'Searching and showing Avis incognita observations' do
    create(:observation, species_id: 0, observ_date: "2010-06-18")
    create(:observation, species_id: 0, observ_date: "2009-06-19")
    create(:observation, species: seed(:spinus), observ_date: "2010-06-18")
    login_as_admin
    visit observations_path
    select('- Avis incognita', from: 'Species')
    click_button('Search')
    page.driver.response.status.should eq(200)
    find('table.obs_list').should have_content('- Avis incognita')
    find('table.obs_list').should_not have_content('Spinus spinus')
  end

  test 'Searching observations by species works properly' do
    create(:observation, species: seed(:acaflm), observ_date: "2010-06-18")
    create(:observation, species: seed(:spinus), observ_date: "2010-06-18")
    login_as_admin
    visit observations_path
    select('Acanthis flammea', from: 'Species')
    click_button('Search')
    find('table.obs_list').should have_content('Acanthis flammea')
    find('table.obs_list').should_not have_content('Spinus spinus')
  end

  test 'Searching observations by mine/not mine works properly' do
    create(:observation, species: seed(:acaflm), observ_date: "2010-06-18", mine: false)
    create(:observation, species: seed(:spinus), observ_date: "2010-06-18")
    login_as_admin
    visit observations_path
    choose('Not mine')
    click_button('Search')
    find('table.obs_list').should have_content('Acanthis flammea')
    find('table.obs_list').should_not have_content('Spinus spinus')
  end

end
