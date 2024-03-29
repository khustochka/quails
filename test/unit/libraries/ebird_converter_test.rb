# frozen_string_literal: true

require "test_helper"
require "export/ebird/observation"

class EBirdConverterTest < ActiveSupport::TestCase
  def ebird_observation(obs)
    Export::EBird::Observation.new(obs)
  end

  def travel_card
    FactoryBot.create(:card, effort_type: "TRAVEL", distance_kms: 1.1)
  end

  test "that distance in miles is used" do
    card = travel_card
    obs = FactoryBot.create(:observation, card: card)
    assert_equal "0.683", ebird_observation(obs).distance_miles.to_s[0..4]
  end

  test "properly sum count" do
    obs = FactoryBot.create(:observation, quantity: "5 + 1")
    assert_equal 6, ebird_observation(obs).count
  end

  test "X mark if count is a string" do
    obs = FactoryBot.create(:observation, quantity: "many")
    assert_equal "X", ebird_observation(obs).count
  end

  test "correctly process empty distance" do
    obs = FactoryBot.create(:observation)
    assert_predicate ebird_observation(obs).distance_miles, :blank?
  end

  test "that date is properly formatted (American format)" do
    card = FactoryBot.create(:card, observ_date: "2014-02-12")
    obs = FactoryBot.create(:observation, card: card)
    assert_equal "02/12/2014", ebird_observation(obs).date
  end

  test "that card locus is properly presented" do
    card = FactoryBot.create(:card, locus: loci(:kyiv))
    obs = FactoryBot.create(:observation, card: card)
    assert_equal "Kyiv City", ebird_observation(obs).location_name
  end

  test "should include images" do
    obs = FactoryBot.create(:observation)
    img1 = FactoryBot.create(:image, slug: "img1", observation_ids: [obs.id])
    img2 = FactoryBot.create(:image, slug: "img2", observation_ids: [obs.id])
    comments = ebird_observation(obs).comments
    assert_includes comments, img1.slug
    assert_includes comments, img2.slug
  end

  test "should include video" do
    video = FactoryBot.create(:video)
    obs = video.observations.first
    comments = ebird_observation(obs).comments
    assert_includes comments, video.external_id
  end

  test "it properly marks species to ebird taxon" do
    obs = FactoryBot.create(:observation, taxon: taxa(:pasdom))
    assert_equal "Passer domesticus", ebird_observation(obs).latin_name
    assert_equal "House Sparrow", ebird_observation(obs).common_name
  end

  test "it properly marks spuh to ebird taxon" do
    obs = FactoryBot.create(:observation, taxon: taxa(:aves_sp))
    assert_equal "Aves sp.", ebird_observation(obs).latin_name
    assert_equal "bird sp.", ebird_observation(obs).common_name
  end

  test "that Motacilla feldegg is marked properly" do
    obs = FactoryBot.create(:observation, taxon: taxa(:motfel))
    assert_equal "Motacilla flava feldegg", ebird_observation(obs).latin_name
    assert_equal "Western Yellow Wagtail (Black-headed)", ebird_observation(obs).common_name
  end
end
