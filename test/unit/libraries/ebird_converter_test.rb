require 'test_helper'
require 'export/ebird/observation'

class EbirdConverterTest < ActiveSupport::TestCase

  def ebird_observation(obs)
    EbirdObservation.new(obs)
  end

  def travel_card
    FactoryGirl.create(:card, effort_type: 'TRAVEL', distance_kms: 1.1)
  end

  test "that distance in miles is used" do
    card = travel_card
    obs = FactoryGirl.create(:observation, card: card)
    assert_equal "0.683", ebird_observation(obs).send(:distance_miles).to_s[0..4]
  end

  test "properly sum count" do
    obs = FactoryGirl.create(:observation, quantity: '5 + 1')
    assert_equal 6, ebird_observation(obs).send(:count)
  end

  test "count is a string" do
    obs = FactoryGirl.create(:observation, quantity: 'many')
    assert_equal nil, ebird_observation(obs).send(:count)
  end

  test "correctly process empty distance" do
    obs = FactoryGirl.create(:observation)
    assert ebird_observation(obs).send(:distance_miles).blank?
  end

  test "that date is properly formatted (American format)" do
    card = FactoryGirl.create(:card, observ_date: '2014-02-12')
    obs = FactoryGirl.create(:observation, card: card)
    assert_equal "02/12/2014", ebird_observation(obs).send(:date)
  end

  test "that card locus is properly presented" do
    card = FactoryGirl.create(:card, locus: loci(:kiev))
    obs = FactoryGirl.create(:observation, card: card)
    assert_equal "Kiev City", ebird_observation(obs).send(:location_name)
  end

  test "that patch locus is properly presented" do
    card = FactoryGirl.create(:card, locus: loci(:kiev_obl))
    obs = FactoryGirl.create(:observation, card: card, patch: loci(:kiev))
    assert_equal "Kiev City", ebird_observation(obs).send(:location_name)
  end

  test "patch locus should not be shown for travel card" do
    card = FactoryGirl.create(:card, locus: loci(:kiev_obl), effort_type: 'TRAVEL')
    obs = FactoryGirl.create(:observation, card: card, patch: loci(:kiev))
    assert_equal "Kiev oblast", ebird_observation(obs).send(:location_name)
  end

  test "should include images" do
    obs = FactoryGirl.create(:observation)
    img1 = FactoryGirl.create(:image, slug: 'img1', observation_ids: [obs.id])
    img2 = FactoryGirl.create(:image, slug: 'img2', observation_ids: [obs.id])
    comments = ebird_observation(obs).send(:comments)
    assert_includes comments, img1.slug
    assert_includes comments, img2.slug
  end

  test "should include video" do
    video = FactoryGirl.create(:video)
    obs = video.observations.first
    comments = ebird_observation(obs).send(:comments)
    assert_includes comments, video.external_id
  end

  test "it properly marks species to ebird taxon" do
    raise
  end

  test "it properly marks spuh to ebird taxon" do
    raise
    obs = FactoryGirl.create(:observation, taxon: taxa(:aves_sp), notes: 'Corvus sp')
    assert_equal "Corvus sp", ebird_observation(obs).send(:latin_name)
    assert_equal "Corvus sp", ebird_observation(obs).send(:common_name)
  end

  test "that unidentified species name is properly trimmed" do
    # Ebird accepts no more than 64 chars in species name
    notes = "Accipiter sp or other raptor: seemed large (like a large crow). from below: light, finely streaked, from above: brownish"
    obs = FactoryGirl.create(:observation, taxon: taxa(:aves_sp), notes: notes)
    assert_equal notes[0..63], ebird_observation(obs).send(:latin_name)
    assert_equal notes[0..63], ebird_observation(obs).send(:common_name)
  end

  test "that Motacilla feldegg is marked properly" do
    card = FactoryGirl.create(:card, locus: loci(:brovary))
    obs = FactoryGirl.create(:observation, taxon: taxa(:motfel), card: card)
    assert_equal "Motacilla flava feldegg", ebird_observation(obs).send(:latin_name)
    assert_equal "Western Yellow Wagtail (Black-headed)", ebird_observation(obs).send(:common_name)
  end

end
