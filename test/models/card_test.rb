# frozen_string_literal: true

require "test_helper"

class CardTest < ActiveSupport::TestCase

  test "#first_unebirded_date" do
    card1 = create(:card, observ_date: "2016-01-01")
    card2 = create(:card, observ_date: "2016-01-02")
    card3 = create(:card, observ_date: "2016-01-03")
    file = Ebird::File.create!(name: "newfile", cards: [card1])
    assert_equal card2.observ_date, Card.first_unebirded_date
  end

  test "#first_unebirded_date works properly for REMOVED" do
    card1 = create(:card, observ_date: "2016-01-01")
    card2 = create(:card, observ_date: "2016-01-02")
    card3 = create(:card, observ_date: "2016-01-03")
    file1 = Ebird::File.create!(name: "newfile", cards: [card2], status: "REMOVED")
    file2 = Ebird::File.create!(name: "newfile", cards: [card1])
    assert_equal card2.observ_date, Card.first_unebirded_date
  end

  test "#first_unebirded_date works properly for REMOVED and then recreated" do
    card1 = create(:card, observ_date: "2016-01-01")
    card2 = create(:card, observ_date: "2016-01-02")
    card3 = create(:card, observ_date: "2016-01-03")
    file1 = Ebird::File.create!(name: "newfile", cards: [card1], status: "REMOVED")
    file2 = Ebird::File.create!(name: "newfile", cards: [card1])
    assert_equal card2.observ_date, Card.first_unebirded_date
  end

  test "#first_unebirded_date for no cards" do
    assert_equal 0, Card.all.count
    assert_nil Card.first_unebirded_date
  end

  test "#last_unebirded_date" do
    card1 = create(:card, observ_date: "2016-01-01")
    card2 = create(:card, observ_date: "2016-01-02")
    card3 = create(:card, observ_date: "2016-01-03")
    file = Ebird::File.create!(name: "newfile", cards: [card1])
    assert_equal card3.observ_date, Card.last_unebirded_date
  end

  test "ebird_eligible scope" do
    card1 = create(:card, effort_type: "TRAVEL")
    card2 = create(:card, effort_type: "TRAVEL")
    obs1 = create(:observation, quantity: "2-3", card: card1)
    obs2 = create(:observation, quantity: "a lot", card: card2)
    ee = Card.ebird_eligible.to_a
    assert_includes ee, card1
    assert_not_includes ee, card2
  end

  test "#lifer_species_ids should return result only on the first card of the day" do
    # If a life was seen on a several cards of one day, if should only be reported on one
    card1 = create(:card, observ_date: "2016-01-01", start_time: "8:00")
    card2 = create(:card, observ_date: "2016-01-01", start_time: "11:30")
    obs1 = create(:observation, card: card1)
    obs2 = create(:observation, card: card2)
    species = obs1.taxon.species
    assert_includes card1.lifer_species_ids, species.id
    assert_not_includes card2.lifer_species_ids, species.id
  end

  test "#lifer_species_ids should prefer cards with time to cards without time" do
    # If a life was seen on a several cards of one day, if should only be reported on one
    card1 = create(:card, observ_date: "2016-01-01")
    card2 = create(:card, observ_date: "2016-01-01", start_time: "11:30")
    obs1 = create(:observation, card: card1)
    obs2 = create(:observation, card: card2)
    species = obs1.taxon.species
    assert_includes card2.lifer_species_ids, species.id
    assert_not_includes card1.lifer_species_ids, species.id
  end

  test "#lifer_species_ids should still work for cards with no time" do
    # If a life was seen on a several cards of one day, if should only be reported on one
    card1 = create(:card, observ_date: "2016-01-01")
    obs1 = create(:observation, card: card1)
    card2 = create(:card, observ_date: "2016-01-01")
    obs2 = create(:observation, card: card2)
    species = obs1.taxon.species
    assert_includes card1.lifer_species_ids, species.id
    assert_not_includes card2.lifer_species_ids, species.id
  end

  test "card is unlinked from post when post is destroyed" do
    p = create(:post)
    card = create(:card, post_id: p.id)
    p.destroy
    assert_nil card.reload.post_id
  end
end
