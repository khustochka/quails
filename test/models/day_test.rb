# frozen_string_literal: true

require "test_helper"

class DayTest < ActiveSupport::TestCase
  test "lifer_species_ids includes species first seen on this date" do
    card = create(:card, observ_date: "2016-01-01")
    obs = create(:observation, card: card)
    later_card = create(:card, observ_date: "2016-02-01")
    create(:observation, card: later_card)

    assert_includes Day.new(Date.new(2016, 1, 1)).lifer_species_ids, obs.species_id
  end

  test "lifer_species_ids excludes species seen on an earlier date" do
    earlier_card = create(:card, observ_date: "2015-12-01")
    create(:observation, card: earlier_card)
    card = create(:card, observ_date: "2016-01-01")
    obs = create(:observation, card: card)

    assert_not_includes Day.new(Date.new(2016, 1, 1)).lifer_species_ids, obs.species_id
  end

  test "lifer_species_ids counts species once when seen on several cards of the date" do
    card1 = create(:card, observ_date: "2016-01-01", start_time: "8:00")
    card2 = create(:card, observ_date: "2016-01-01", start_time: "11:30")
    obs = create(:observation, card: card1)
    create(:observation, card: card2)

    assert_equal [obs.species_id], Day.new(Date.new(2016, 1, 1)).lifer_species_ids
  end
end
