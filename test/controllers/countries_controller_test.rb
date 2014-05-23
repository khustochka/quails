require 'test_helper'

class CountriesControllerTest < ActionController::TestCase
  setup do
    @image = create(:image)
    assert seed(:pasdom).image
    @obs = @image.observations.first
  end

  test 'Birds of Ukraine' do
    get :gallery, country: 'ukraine', locale: :ru
    assert_response :success
    assert assigns(:species).present?
    assert_select "a[href=#{species_path(@obs.species)}]"
  end

  test "Birds of USA" do
    create(:observation, card: create(:card, locus: seed(:queens)))
    get :gallery, country: 'usa', locale: :ru
    assert_response :success
    assert assigns(:species).present?
    assert_select "a[href=#{species_path(@obs.species)}]"
  end

end
