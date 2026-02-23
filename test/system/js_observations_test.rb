# frozen_string_literal: true

require "application_system_test_case"

class JSObservationsTest < ApplicationSystemTestCase
  test "Edit observation - change species" do
    observation = create(:observation, voice: true)

    login_as_admin
    visit observation_path(observation)
    select_suggestion("Hirundo rustica", from: "Taxon")
    assert_difference("Observation.count", 0) { save_and_check }
    observation.reload
    assert_equal "Hirundo rustica", observation.species.name_sci
  end

  private

  def save_and_check
    click_button("Save")
    assert_css "#save_button[value=Save]"
  end
end
