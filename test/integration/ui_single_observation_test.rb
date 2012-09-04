require 'test_helper'
require 'capybara_helper'

class UISingleObservationTest < ActionDispatch::IntegrationTest

  include CapybaraTestCase

  test 'Adding one observation - not voice (JS off)' do
    login_as_admin
    visit add_observations_path
    assert_equal 1, all('.obs-row').size
    select('Brovary', from: 'Location')
    fill_in('Date', with: '2011-04-08')
    select('Cyanistes caeruleus', from: 'Species')
    select 'park', from: 'Biotope'
    assert_difference('Observation.count', 1) { submit_form_with('Save') }
    assert_false Observation.order('id DESC').limit(1).first.voice
  end

  test 'Adding one observation - voice only (JS off)' do
    login_as_admin
    visit add_observations_path
    assert_equal 1, all('.obs-row').size
    select('Brovary', from: 'Location')
    fill_in('Date', with: '2011-04-08')
    select('Cyanistes caeruleus', from: 'Species')
    check('Voice?')
    select 'park', from: 'Biotope'
    assert_difference('Observation.count', 1) { submit_form_with('Save') }
    assert Observation.order('id DESC').limit(1).first.voice
  end

  test 'Edit observation - uncheck voice only' do
    observation = create(:observation, voice: true)
    login_as_admin
    visit edit_observation_path(observation)
    assert_equal 1, all('.obs-row').size
    assert page.has_checked_field?('Voice?')
    uncheck('Voice?')
    assert_difference('Observation.count', 0) { submit_form_with('Save') }
    observation.reload
    assert_false observation.voice
  end

end
