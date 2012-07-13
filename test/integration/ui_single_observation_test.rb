require 'test_helper'
require 'capybara_helper'

class UISingleObservationTest < ActionDispatch::IntegrationTest

  include CapybaraTestCase

  test 'Adding one observation - not voice (JS off)' do
    login_as_admin
    visit add_observations_path
    expect(all('.obs-row').size).to eq(1)
    select('Brovary', from: 'Location')
    fill_in('Date', with: '2011-04-08')
    select('Cyanistes caeruleus', from: 'Species')
    select 'park', from: 'Biotope'
    expect(lambda { submit_form_with('Save') }).to change(Observation, :count).by(1)
    expect(Observation.order('id DESC').limit(1).first.voice).to be_false
  end

  test 'Adding one observation - voice only (JS off)' do
    login_as_admin
    visit add_observations_path
    expect(all('.obs-row').size).to eq(1)
    select('Brovary', from: 'Location')
    fill_in('Date', with: '2011-04-08')
    select('Cyanistes caeruleus', from: 'Species')
    check('Voice?')
    select 'park', from: 'Biotope'
    expect(lambda { submit_form_with('Save') }).to change(Observation, :count).by(1)
    expect(Observation.order('id DESC').limit(1).first.voice).to be_true
  end

  test 'Edit observation - uncheck voice only' do
    observation = create(:observation, voice: true)
    login_as_admin
    visit edit_observation_path(observation)
    expect(all('.obs-row').size).to eq(1)
    expect(page).to have_checked_field('Voice?')
    uncheck('Voice?')
    expect(lambda { submit_form_with('Save') }).to change(Observation, :count).by(0)
    observation.reload
    expect(observation.voice).to be_false
  end

end
