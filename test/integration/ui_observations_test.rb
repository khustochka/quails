# frozen_string_literal: true

require "test_helper"
require "capybara_helper"

class UIObservationsTest < ActionDispatch::IntegrationTest
  include CapybaraTestCase

  test "Edit observation - uncheck voice only" do
    observation = create(:observation, voice: true)
    login_as_admin
    visit observation_path(observation)
    assert_equal 1, all(".obs-row").size
    assert_checked_field "Voice?"
    uncheck("Voice?")
    assert_difference("Observation.count", 0) { click_button("Save") }
    observation.reload
    assert_not observation.voice
  end

  test "Extract single observation to the new card" do
    card = create(:card)
    obs1 = create(:observation, card: card)
    create(:observation, card: card)
    create(:observation, card: card)

    login_as_admin
    visit observation_path(obs1)
    assert_difference("Card.count", 1) {
      assert_difference("Observation.count", 0) { click_link("Extract to the new card") }
    }

    card.reload
    obs1.reload
    assert_current_path edit_card_path(obs1.card)

    assert_equal 2, card.observations.size
    assert_not_equal card, obs1.card
  end
end
