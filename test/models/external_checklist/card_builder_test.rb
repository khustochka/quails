# frozen_string_literal: true

require "test_helper"

class ExternalChecklist::CardBuilderTest < ActiveSupport::TestCase
  def build_card(**data)
    ExternalChecklist::CardBuilder.new("S123", {
      observ_date: "2026-09-19", start_time: "07:05", protocol: "Traveling", duration_minutes: 95,
      distance_kms: 3.2, observers: 1, notes: "Nice morning", complete: true,
      observations: [{ name: "House Sparrow", species_code: "houspa", count: "5", comments: "", obs_id: "OBS1" }],
    }.merge(data)).card
  end

  test "builds card from checklist data" do
    card = build_card

    assert_equal "S123", card.ebird_id
    assert_equal Date.new(2026, 9, 19), card.observ_date
    assert_equal "07:05", card.start_time
    assert_equal "TRAVEL", card.effort_type
    assert_equal 95, card.duration_minutes
    assert_in_delta 3.2, card.distance_kms
    assert_nil card.observers
    assert_equal "Nice morning", card.notes
    assert_not card.motorless
    assert card.ebird_complete
  end

  test "builds observations" do
    obs = build_card.observations.sole

    assert_equal taxa(:pasdom), obs.taxon
    assert_equal "5", obs.quantity
    assert_equal "OBS1", obs.ebird_obs_id
    assert_not obs.voice
  end

  test "keeps party size above one" do
    assert_equal "3", build_card(observers: 3).observers
  end

  test "ML notes mark card motorless" do
    assert build_card(notes: "ML").motorless
    assert_equal "", build_card(notes: "ML").notes
    assert_equal "ML, walked", build_card(notes: "ML, walked").notes
  end

  test "X count means no quantity" do
    assert_nil build_card(observations: [{ name: "House Sparrow", count: "X" }]).observations.sole.quantity
  end

  test "heard only comments mark observation as voice" do
    obs = build_card(observations: [{ name: "House Sparrow", count: "1", comments: "V\nin the bushes" }]).observations.sole
    assert_not obs.voice

    obs = build_card(observations: [{ name: "House Sparrow", count: "1", comments: "V" }]).observations.sole
    assert obs.voice
    assert_equal "", obs.notes

    assert build_card(observations: [{ name: "House Sparrow", count: "1", comments: "Heard only, far" }]).observations.sole.voice
  end

  test "finds taxon by species code when name does not match" do
    obs = build_card(observations: [{ name: "Passer domesticus", species_code: "houspa", count: "1" }]).observations.sole

    assert_equal taxa(:pasdom), obs.taxon
  end

  test "raises on unknown taxon" do
    error = assert_raises(ExternalChecklist::CardBuilder::Error) do
      build_card(observations: [{ name: "Dodo", species_code: "dodo1", count: "1" }])
    end
    assert_equal "Unknown taxon: Dodo (dodo1).", error.message
  end
end
