# frozen_string_literal: true

require "test_helper"

class ImageMapTest < ActiveSupport::TestCase
  setup do
    @public_spot = FactoryBot.create(:spot, public: true, lat: 1)
    @private_spot = FactoryBot.create(:spot, public: false, lat: 2)

    @country = loci(:ukraine)
    @overlocus = FactoryBot.create(:locus, private_loc: false, lat: 3, parent: @country)
    @overlocus_no_geo = FactoryBot.create(:locus, private_loc: false, lat: nil, lon: nil, parent: @country)

    @public_locus = FactoryBot.create(:locus, private_loc: false, lat: 4, parent: @overlocus)
    @private_locus = FactoryBot.create(:locus, private_loc: true, lat: 5, parent: @overlocus)
    @public_locus_no_geo = FactoryBot.create(:locus, private_loc: false, lat: nil, parent: @overlocus)

    @public_patch = FactoryBot.create(:locus, private_loc: false, lat: 6, parent: @public_locus)
    @private_patch_of_public_locus = FactoryBot.create(:locus, private_loc: true, lat: 7, parent: @public_locus)
    @private_patch_of_private_locus = FactoryBot.create(:locus, private_loc: true, lat: 8, parent: @private_locus)

    @public_patch_no_geo_of_public_locus = FactoryBot.create(:locus, private_loc: false, lat: nil, parent: @public_locus)
    @public_patch_no_geo_of_private_locus = FactoryBot.create(:locus, private_loc: false, lat: nil, parent: @private)
  end

  def private_spot(args = {})
    FactoryBot.create(:spot, {public: false, lat: 2}.merge(args))
  end

  def public_spot(args = {})
    FactoryBot.create(:spot, {public: true, lat: 1}.merge(args))
  end

  def megafactory(card_locus, observation_patch, spot_factory)
    card_args = {locus: card_locus}.compact
    @card = create(:card, card_args)
    obs_args = {patch: observation_patch, card: @card}.compact
    @observation = create(:observation, obs_args)
    @spot = if spot_factory
              send(spot_factory, observation: @observation)
            end
    create(:image, observations: [@observation], spot: @spot)
  end

  def result
    Media.for_the_map_query.where(id: @image.id).first
  end

  # image for the map

  test "image with public spot" do
    @image = megafactory(nil, nil, :public_spot)
    assert result
    assert_equal @spot.lat, result.lat
  end

  test "image with private spot and public patch" do
    @image = megafactory(nil, @public_patch, :private_spot)
    assert result
    assert_equal @public_patch.lat, result.lat
  end

  test "image with private spot, no patch and public locus" do
    @image = megafactory(@public_locus, nil, :private_spot)
    assert result
    assert_equal @public_locus.lat, result.lat
  end

  # NOTE: though logically observation patch must be a descendant
  # of the card locus, it is not forced and does not impact anything.

  test "image with private spot, private patch and public locus" do
    @image = megafactory(@public_locus, @private_patch_of_public_locus, :private_spot)
    assert result
    assert_equal @public_locus.lat, result.lat
  end

  test "image with no spot and public patch" do
    @image = megafactory(nil, @public_patch, nil)
    assert result
    assert_equal @public_patch.lat, result.lat
  end

  test "image with no spot, no patch and public locus" do
    @image = megafactory(@public_locus, nil, nil)
    assert result
    assert_equal @public_locus.lat, result.lat
  end

  test "image with no spot, no patch and private locus" do
    @image = megafactory(@private_locus, nil, nil)
    assert result
    assert_equal @overlocus.lat, result.lat
  end

  test "image with no spot, no patch and locus with no latlng but parent with geo" do
    @image = megafactory(@public_locus_no_geo, nil, nil)
    assert result
    assert_equal @overlocus.lat, result.lat
  end

  test "image with no spot, no patch and locus with no latlng and parent with no latlng" do
    @image = megafactory(@overlocus_no_geo, nil, nil)
    assert_nil result
  end
end
