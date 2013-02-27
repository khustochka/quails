require 'test_helper'

class CountriesControllerTest < ActionController::TestCase
  setup do
    @image = create(:image)
    seed(:pasdom).update_column(:image_id, @image.id)
    @obs = @image.observations.first
  end

  test 'Birds of Ukraine' do
    get :gallery, country: 'ukraine'
    assert_response :success
    assert assigns(:species).present?
    assert_select "a[href=#{species_path(@obs.species)}]"
  end

  test "Birds of USA" do
    create(:observation, locus: seed(:queens))
    get :gallery, country: 'usa'
    assert_response :success
    assert assigns(:species).present?
    assert_select "a[href=#{species_path(@obs.species)}]"
  end

end
