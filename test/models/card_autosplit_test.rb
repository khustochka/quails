# frozen_string_literal: true

require "test_helper"

class CardTest < ActiveSupport::TestCase
  test "card without patches does not change" do
    obs = create(:observation, patch_id: nil)
    card = obs.card
    assert_difference "Card.count", 0 do
      card.autosplit
    end
  end

  test "card with start time raises exception" do
    card = create(:card, start_time: "17:00")
    obs = create(:observation, card: card, patch: loci(:nyc))
    card = obs.card
    assert_raise do
      card.autosplit
    end
  end

  test "card with effort_type TRAVEL raises exception" do
    card = create(:card, effort_type: "TRAVEL")
    obs = create(:observation, card: card, patch: loci(:nyc))
    assert_raise do
      card.autosplit
    end
  end

  test "card with patch observations is properly split" do
    result = nil
    card = create(:card)
    obs1 = create(:observation, card: card, patch: loci(:nyc))
    obs2 = create(:observation, card: card, patch: loci(:nyc))
    obs3 = create(:observation, card: card, patch: nil)
    obs4 = create(:observation, card: card, patch: nil)
    obs5 = create(:observation, card: card, patch: loci(:usa))
    obs6 = create(:observation, card: card, patch: loci(:usa))
    assert_difference "Card.count", 2 do
      result = card.autosplit
    end
    card1, card2, card3 = result
    assert_equal 2, card1.observations.count
    assert_equal 2, card2.observations.count
    assert_equal 2, card3.observations.count
    assert_equal card.id, card3.id
  end

  test "card with only patch observations is properly split" do
    result = nil
    card = create(:card)
    obs1 = create(:observation, card: card, patch: loci(:nyc))
    obs2 = create(:observation, card: card, patch: loci(:nyc))
    obs3 = create(:observation, card: card, patch: loci(:usa))
    obs4 = create(:observation, card: card, patch: loci(:usa))
    assert_difference "Card.count", 1 do
      result = card.autosplit
    end
    card1, card2 = result
    assert_equal 2, card1.observations.count
    assert_equal 2, card2.observations.count
    assert_equal card.id, card2.id
    assert_equal loci(:usa).id, card2.locus_id
    assert_nil obs1.reload.patch_id
    assert_nil obs2.reload.patch_id
    assert_nil obs3.reload.patch_id
    assert_nil obs4.reload.patch_id
  end

  test "card with single patch observations is properly split" do
    card = create(:card)
    obs1 = create(:observation, card: card, patch: loci(:nyc))
    obs2 = create(:observation, card: card, patch: loci(:nyc))
    assert_difference "Card.count", 0 do
      card.autosplit
    end
    assert_nil obs1.reload.patch_id
    assert_nil obs2.reload.patch_id
    assert_equal loci(:nyc).id, card.locus_id
  end
end
