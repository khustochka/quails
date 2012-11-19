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
    assert_present assigns(:species)
    assert_select "a[href=#{species_path(@obs.species)}]"
  end

  test "Birds of USA" do
    create(:observation, locus: seed(:queens))
    get :gallery, country: 'usa'
    assert_response :success
    assert_present assigns(:species)
    assert_select "a[href=#{species_path(@obs.species)}]"
  end

  test 'shows checklist for Ukraine' do
    get :checklist, country: 'ukraine'
    assert_response :success
    assert_present assigns(:checklist)
  end

  test 'do not show checklist for unknown countries' do
    assert_raise(ActionController::RoutingError) { get :checklist, country: 'georgia' }
  end

end