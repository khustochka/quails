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

  test "that distance in miles is used" do
    card = travel_card
    obs = FactoryGirl.create(:observation, card: card)
    assert_equal "0.683", oconv(obs).send(:distance_miles).to_s[0..4]
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

  test "should include images" do
    obs = FactoryGirl.create(:observation)
    img1 = FactoryGirl.create(:image, slug: 'img1', observation_ids: [obs.id])
    img2 = FactoryGirl.create(:image, slug: 'img2', observation_ids: [obs.id])
    comments = oconv(obs).send(:comments)
    assert_includes comments, img1.slug
    assert_includes comments, img2.slug
  end

  test "that unidentified species is marked properly" do
    skip
  end

  test "that Feral Pigeon is marked properly" do
    skip
  end

  test "that Hirundo rustica is marked properly when seen in Ukraine" do
    skip
  end

  test "that Hirundo rustica is marked properly when seen in USA" do
    skip
  end

  test "that Larus argentatus is marked properly when seen in Ukraine" do
    skip
  end

  test "that Larus argentatus is marked properly when seen in USA" do
    skip
  end

  test "that Larus heuglini is marked properly when seen in UK" do
    skip
  end

  test "that Motacilla feldegg is marked properly" do
    skip
  end

end
