require 'test_helper'
require 'ebird/converter_factory'

class EbirdConverterTest < ActiveSupport::TestCase

  setup do
    @converter = EbirdConverterFactory.new(nil)
  end

  def oconv(obs)
    @converter.new(obs)
  end

  def travel_card
    FactoryGirl.create(:card, effort_type: 'TRAVEL', distance_kms: 1.1)
  end

  test "that distance in miles is used" do
    card = travel_card
    obs = FactoryGirl.create(:observation, card: card)
    assert_equal "0.683", oconv(obs).send(:distance_miles).to_s[0..4]
  end

  test "properly sum count" do
    obs = FactoryGirl.create(:observation, quantity: '5 + 1')
    assert_equal 6, oconv(obs).send(:count)
  end

  test "count is a string" do
    obs = FactoryGirl.create(:observation, quantity: 'many')
    assert_equal nil, oconv(obs).send(:count)
  end

  test "correctly process empty distance" do
    obs = FactoryGirl.create(:observation)
    assert oconv(obs).send(:distance_miles).blank?
  end

  test "that date is properly formatted (American format)" do
    card = FactoryGirl.create(:card, observ_date: '2014-02-12')
    obs = FactoryGirl.create(:observation, card: card)
    assert_equal "02/12/2014", oconv(obs).send(:date)
  end

  test "that card locus is properly presented" do
    card = FactoryGirl.create(:card, locus: seed(:kiev))
    obs = FactoryGirl.create(:observation, card: card)
    assert_equal "Kiev City", oconv(obs).send(:location_name)
  end

  test "that patch locus is properly presented" do
    card = FactoryGirl.create(:card, locus: seed(:kiev))
    obs = FactoryGirl.create(:observation, card: card, patch: seed(:expocenter))
    assert_equal "Expocentre", oconv(obs).send(:location_name)
  end

  test "should include images" do
    obs = FactoryGirl.create(:observation)
    img1 = FactoryGirl.create(:image, slug: 'img1', observation_ids: [obs.id])
    img2 = FactoryGirl.create(:image, slug: 'img2', observation_ids: [obs.id])
    comments = oconv(obs).send(:comments)
    assert_includes comments, img1.slug
    assert_includes comments, img2.slug
  end

  test "that the same correct latin name is used (Clements 6)" do
    obs = FactoryGirl.create(:observation, species: seed(:pasdom))
    assert_equal "Passer domesticus", oconv(obs).send(:latin_name)
  end

  test "that the different correct latin name is used (Clements 6)" do
    obs = FactoryGirl.create(:observation, species: seed(:acacan))
    assert_equal "Carduelis cannabina", oconv(obs).send(:latin_name)
  end

  test "that the correct latin name is used for problematic species (Clements 6)" do
    obs = FactoryGirl.create(:observation, species: seed(:saxtor))
    assert_equal "Saxicola rubicola", oconv(obs).send(:latin_name)
  end

  test "that unidentified species is marked properly" do
    obs = FactoryGirl.create(:observation, species_id: 0, notes: 'Corvus sp')
    assert_equal "Corvus sp", oconv(obs).send(:latin_name)
    assert_equal "Corvus sp", oconv(obs).send(:common_name)
  end

  test "that Feral Pigeon is marked properly" do
    obs = FactoryGirl.create(:observation, species: seed(:colliv))
    assert_equal "Columba livia (Domestic type)", oconv(obs).send(:latin_name)
    assert_equal "Rock Pigeon (Feral Pigeon)", oconv(obs).send(:common_name)
  end

  test "that Hirundo rustica is marked properly when seen in Ukraine" do
    card = FactoryGirl.create(:card, locus: seed(:brovary))
    obs = FactoryGirl.create(:observation, species: seed(:hirrus), card: card)
    assert_equal "Hirundo rustica", oconv(obs).send(:latin_name)
    assert_equal "Barn Swallow", oconv(obs).send(:common_name)
  end

  test "that Hirundo rustica is marked properly when seen in USA" do
    card = FactoryGirl.create(:card, locus: seed(:brooklyn))
    obs = FactoryGirl.create(:observation, species: seed(:hirrus), card: card)
    assert_equal "Hirundo rustica erythrogaster", oconv(obs).send(:latin_name)
    assert_equal "Barn Swallow (American)", oconv(obs).send(:common_name)
  end

  test "that Larus argentatus is marked properly when seen in Ukraine" do
    card = FactoryGirl.create(:card, locus: seed(:kiev))
    obs = FactoryGirl.create(:observation, species: seed(:lararg), card: card)
    assert_equal "Larus argentatus", oconv(obs).send(:latin_name)
    assert_equal "Herring Gull", oconv(obs).send(:common_name)
  end

  test "that Larus argentatus smithsonianus is marked properly when seen in USA" do
    card = FactoryGirl.create(:card, locus: seed(:brooklyn))
    obs = FactoryGirl.create(:observation, species: seed(:lararg), card: card)
    assert_equal "Larus argentatus smithsonianus", oconv(obs).send(:latin_name)
    assert_equal "Herring Gull (American)", oconv(obs).send(:common_name)
  end

  test "that Larus fuscus graellsii is marked properly when seen in UK" do
    card = FactoryGirl.create(:card, locus: seed(:london))
    obs = FactoryGirl.create(:observation, species: seed(:larfus), card: card)
    assert_equal "Larus fuscus graellsii", oconv(obs).send(:latin_name)
    assert_equal "Lesser Black-backed Gull (graellsii)", oconv(obs).send(:common_name)
  end

  test "that Motacilla feldegg is marked properly" do
    card = FactoryGirl.create(:card, locus: seed(:arabatska_khersonska))
    obs = FactoryGirl.create(:observation, species: seed(:motfel), card: card)
    assert_equal "Motacilla flava feldegg", oconv(obs).send(:latin_name)
    assert_equal "Western Yellow Wagtail (Black-headed)", oconv(obs).send(:common_name)
  end

end
