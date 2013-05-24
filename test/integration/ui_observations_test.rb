require 'test_helper'
require 'capybara_helper'

class UIObservationsTest < ActionDispatch::IntegrationTest

  include CapybaraTestCase

  test 'Edit observation - uncheck voice only' do
    observation = create(:observation, voice: true)
    login_as_admin
    visit observation_path(observation)
    assert_equal 1, all('.obs-row').size
    assert page.has_checked_field?('Voice?')
    uncheck('Voice?')
    assert_difference('Observation.count', 0) { click_button('Save') }
    observation.reload
    assert_false observation.voice
  end

  test 'Searching and showing Avis incognita observations' do
    card = create(:card, observ_date: "2010-06-18")
    create(:observation, species_id: 0, card: card)
    create(:observation, species_id: 0, card: create(:card, observ_date: "2010-06-19"))
    create(:observation, species: seed(:spinus), card: card)
    login_as_admin
    visit observations_path
    select('- Avis incognita', from: 'Species')
    click_button('Search')
    assert_equal 200, page.driver.response.status
    assert find('table.obs_list').has_content?('- Avis incognita')
    assert_false find('table.obs_list').has_content?('Spinus spinus')
  end

  test 'Searching observations by species works properly' do
    card = create(:card, observ_date: "2010-06-18")
    create(:observation, species: seed(:pasdom), card: card)
    create(:observation, species: seed(:fulatr), card: card)
    login_as_admin
    visit observations_path
    select('Passer domesticus', from: 'Species')
    click_button('Search')
    assert find('table.obs_list').has_content?('Passer domesticus')
    assert_false find('table.obs_list').has_content?('Fulica atra')
  end

  test 'Searching observations by mine/not mine works properly' do
    card = create(:card, observ_date: "2010-06-18")
    create(:observation, species: seed(:pasdom), card: card, mine: false)
    create(:observation, species: seed(:fulatr), card: card)
    login_as_admin
    visit observations_path
    choose('Not mine')
    click_button('Search')
    assert find('table.obs_list').has_content?('Passer domesticus')
    assert_false find('table.obs_list').has_content?('Fulica atra')
  end

end
