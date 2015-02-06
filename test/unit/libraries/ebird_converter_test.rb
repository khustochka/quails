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
    card = FactoryGirl.create(:card, locus: seed(:kiev))
    obs = FactoryGirl.create(:observation, card: card)
    assert_equal "Kiev City", ebird_observation(obs).send(:location_name)
  end

  test "that patch locus is properly presented" do
    card = FactoryGirl.create(:card, locus: seed(:kiev))
    obs = FactoryGirl.create(:observation, card: card, patch: seed(:expocenter))
    assert_equal "Expocentre", ebird_observation(obs).send(:location_name)
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

  test "that the same correct latin name is used (Clements 6)" do
    obs = FactoryGirl.create(:observation, species: seed(:pasdom))
    assert_equal "Passer domesticus", ebird_observation(obs).send(:latin_name)
  end

  test "that the different correct latin name is used (Clements 6)" do
    obs = FactoryGirl.create(:observation, species: seed(:acacan))
    assert_equal "Carduelis cannabina", ebird_observation(obs).send(:latin_name)
  end

  test "that the correct latin name is used for problematic species (Clements 6)" do
    obs = FactoryGirl.create(:observation, species: seed(:saxtor))
    assert_equal "Saxicola rubicola", ebird_observation(obs).send(:latin_name)
  end

  test "that unidentified species is marked properly" do
    obs = FactoryGirl.create(:observation, species_id: 0, notes: 'Corvus sp')
    assert_equal "Corvus sp", ebird_observation(obs).send(:latin_name)
    assert_equal "Corvus sp", ebird_observation(obs).send(:common_name)
  end

  test "that Feral Pigeon is marked properly" do
    obs = FactoryGirl.create(:observation, species: seed(:colliv))
    assert_equal "Columba livia (Feral Pigeon)", ebird_observation(obs).send(:latin_name)
    assert_equal "Rock Pigeon (Feral Pigeon)", ebird_observation(obs).send(:common_name)
  end

  test "that Hirundo rustica is marked properly when seen in Ukraine" do
    card = FactoryGirl.create(:card, locus: seed(:brovary))
    obs = FactoryGirl.create(:observation, species: seed(:hirrus), card: card)
    assert_equal "Hirundo rustica", ebird_observation(obs).send(:latin_name)
    assert_equal "Barn Swallow", ebird_observation(obs).send(:common_name)
  end

  test "that Hirundo rustica is marked properly when seen in USA" do
    card = FactoryGirl.create(:card, locus: seed(:brooklyn))
    obs = FactoryGirl.create(:observation, species: seed(:hirrus), card: card)
    assert_equal "Hirundo rustica erythrogaster", ebird_observation(obs).send(:latin_name)
    assert_equal "Barn Swallow (American)", ebird_observation(obs).send(:common_name)
  end

  test "that Larus argentatus is marked properly when seen in Ukraine" do
    card = FactoryGirl.create(:card, locus: seed(:kiev))
    obs = FactoryGirl.create(:observation, species: seed(:lararg), card: card)
    assert_equal "Larus argentatus", ebird_observation(obs).send(:latin_name)
    assert_equal "Herring Gull", ebird_observation(obs).send(:common_name)
  end

  test "that Larus argentatus smithsonianus is marked properly when seen in USA" do
    card = FactoryGirl.create(:card, locus: seed(:brooklyn))
    obs = FactoryGirl.create(:observation, species: seed(:lararg), card: card)
    assert_equal "Larus argentatus smithsonianus", ebird_observation(obs).send(:latin_name)
    assert_equal "Herring Gull (American)", ebird_observation(obs).send(:common_name)
  end

  test "that Larus fuscus graellsii is marked properly when seen in UK" do
    card = FactoryGirl.create(:card, locus: seed(:london))
    obs = FactoryGirl.create(:observation, species: seed(:larfus), card: card)
    assert_equal "Larus fuscus graellsii", ebird_observation(obs).send(:latin_name)
    assert_equal "Lesser Black-backed Gull (graellsii)", ebird_observation(obs).send(:common_name)
  end

  test "that Motacilla feldegg is marked properly" do
    card = FactoryGirl.create(:card, locus: seed(:arabatska_khersonska))
    obs = FactoryGirl.create(:observation, species: seed(:motfel), card: card)
    assert_equal "Motacilla flava feldegg", ebird_observation(obs).send(:latin_name)
    assert_equal "Western Yellow Wagtail (Black-headed)", ebird_observation(obs).send(:common_name)
  end

end
