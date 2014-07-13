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
    assert_select "a[href=#{species_path(@obs.species)}]"
  end

  test "Birds of USA" do
    obs = create(:observation, card: create(:card, locus: seed(:brooklyn)))
    img = create(:image, observations: [obs])
    get :gallery, country: 'usa'
    assert_response :success
    assert assigns(:thumbs).present?
    assert_select "a[href=#{image_path(img)}]"
  end

  test "Birds of UK" do
    obs = create(:observation, card: create(:card, locus: seed(:london)))
    img = create(:image, observations: [obs])
    get :gallery, country: 'united_kingdom'
    assert_response :success
    assert assigns(:thumbs).present?
    assert_select "a[href=#{image_path(img)}]"
  end

end
