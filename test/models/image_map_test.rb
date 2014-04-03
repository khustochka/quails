require 'test_helper'

class ImageMapTest < ActiveSupport::TestCase

  setup do
    @public_spot = FactoryGirl.create(:spot, public: true, lat: 1)
    @private_spot = FactoryGirl.create(:spot, public: false, lat: 2)

    @country = seed(:ukraine)
    @overlocus = FactoryGirl.create(:locus, private_loc: false, lat: 3, parent: @country)

    @public_locus = FactoryGirl.create(:locus, private_loc: false, lat: 4, parent: @overlocus)
    @private_locus = FactoryGirl.create(:locus, private_loc: true, lat: 5, parent: @overlocus)
    @public_locus_no_geo = FactoryGirl.create(:locus, private_loc: false, lat: nil, parent: @overlocus)

    @public_patch = FactoryGirl.create(:locus, private_loc: false, lat: 6, parent: @public_locus)
    @private_patch_of_public_locus = FactoryGirl.create(:locus, private_loc: true, lat: 7, parent: @public_locus)
    @private_patch_of_private_locus = FactoryGirl.create(:locus, private_loc: true, lat: 8, parent: @private_locus)

    @public_patch_no_geo_of_public_locus = FactoryGirl.create(:locus, private_loc: false, lat: nil, parent: @public_locus)
    @public_patch_no_geo_of_private_locus = FactoryGirl.create(:locus, private_loc: false, lat: nil, parent: @private)

  end

  # image for the map

  test "image with public spot" do
    skip
  end

  test "image with private spot and public patch" do
    skip
  end

  test "image with private spot, no patch and public locus" do
    skip
  end

  test "image with private spot, private patch and public locus" do
    skip
  end

  test "image with no spot and public patch" do
    skip
  end

  test "image with no spot, no patch and public locus" do
    skip
  end

  test "image with no spot, no patch and private locus" do
    skip
  end

  test "image with no spot, no patch and locus with no latlng" do
    skip
  end

end
