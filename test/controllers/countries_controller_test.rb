require 'test_helper'

class CountriesControllerTest < ActionController::TestCase
  setup do
    @image = create(:image)
    assert seed(:pasdom).image
    @obs = @image.observations.first
  end

  test 'Birds of Ukraine' do
    get :gallery, country: 'ukraine'
    assert_response :success
    assert assigns(:thumbs).present?
    assert_select "a[href='#{species_path(@obs.species)}']"
  end

  test "Birds of USA" do
    obs = create(:observation, card: create(:card, locus: loci(:nyc)))
    img = create(:image, observations: [obs])
    get :gallery, country: 'usa'
    assert_response :success
    assert assigns(:thumbs).present?, "Thumbnails must be present, were not."
    assert_select "a[href='#{image_path(img)}']"
  end

  test "Birds of UK" do
    uk = create(:locus, loc_type: "country", slug: "united_kingdom")
    london = create(:locus, parent: uk, slug: "london")
    obs = create(:observation, card: create(:card, locus: london))
    img = create(:image, observations: [obs])
    get :gallery, country: 'united_kingdom'
    assert_response :success
    assert assigns(:thumbs).present?
    assert_select "a[href='#{image_path(img)}']"
  end

end
