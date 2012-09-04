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
    assert_equal 200, page.driver.response.status
    assert find('table.obs_list').has_content?('- Avis incognita')
    assert_false find('table.obs_list').has_content?('Spinus spinus')
  end

  test 'Searching observations by species works properly' do
    create(:observation, species: seed(:acaflm), observ_date: "2010-06-18")
    create(:observation, species: seed(:spinus), observ_date: "2010-06-18")
    login_as_admin
    visit observations_path
    select('Acanthis flammea', from: 'Species')
    click_button('Search')
    assert find('table.obs_list').has_content?('Acanthis flammea')
    assert_false find('table.obs_list').has_content?('Spinus spinus')
  end

  test 'Searching observations by mine/not mine works properly' do
    create(:observation, species: seed(:acaflm), observ_date: "2010-06-18", mine: false)
    create(:observation, species: seed(:spinus), observ_date: "2010-06-18")
    login_as_admin
    visit observations_path
    choose('Not mine')
    click_button('Search')
    assert find('table.obs_list').has_content?('Acanthis flammea')
    assert_false find('table.obs_list').has_content?('Spinus spinus')
  end

end
