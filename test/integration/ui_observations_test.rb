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
    refute observation.voice
  end

  test 'Extract single observation to the new card' do
    card = create(:card)
    obs1 = create(:observation, card: card)
    create(:observation, card: card)
    create(:observation, card: card)

    login_as_admin
    visit observation_path(obs1)
    assert_difference('Card.count', 1) {
      assert_difference('Observation.count', 0) { click_link('Extract to the new card') }
    }

    card.reload
    obs1.reload
    assert_equal edit_card_path(obs1.card), current_path

    assert_equal 2, card.observations.size
    assert card != obs1.card
  end

end
