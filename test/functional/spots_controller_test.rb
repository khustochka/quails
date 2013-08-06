require 'test_helper'

class SpotsControllerTest < ActionController::TestCase

  test "returns spots" do
    obs1 = create(:observation, card: create(:card, observ_date: '2010-07-24'))
    obs2 = create(:observation, card: create(:card, observ_date: '2011-07-24'))
    create(:spot, observation: obs1)
    create(:spot, observation: obs2)
    get :index, format: :json
    assert_response :success
    assert_equal Mime::JSON, response.content_type
  end

  test "returns photos having spots" do
    obs1 = create(:observation, card: create(:card, observ_date: '2010-07-24'))
    obs2 = create(:observation, card: create(:card, observ_date: '2011-07-24'))
    spot1 = create(:spot, observation: obs1)
    spot2 = create(:spot, observation: obs2)
    create(:image, observations: [obs1], spot_id: spot1.id)
    get :photos, format: :json
    assert_response :success
    assert_equal Mime::JSON, response.content_type
    assert_equal 1, JSON.parse(response.body).size
  end

  test "returns photos attached to the city" do
    obs1 = create(:observation, card: create(:card, observ_date: '2010-07-24'))
    obs2 = create(:observation, card: create(:card, observ_date: '2011-07-24'))
    spot1 = create(:spot, observation: obs1)
    create(:image, observations: [obs1], spot_id: spot1.id)
    create(:image, observations: [obs2])
    get :photos, format: :json
    assert_response :success
    assert_equal Mime::JSON, response.content_type
    assert_equal 2, JSON.parse(response.body).size
  end

  test "correctly process photos attached to a country (no latlng)" do
    obs1 = create(:observation, card: create(:card, observ_date: '2010-07-24'))
    obs2 = create(:observation, card: create(:card, observ_date: '2011-07-24', locus: seed(:ukraine)))
    spot1 = create(:spot, observation: obs1)
    create(:image, observations: [obs1], spot_id: spot1.id)
    create(:image, observations: [obs2])
    get :photos, format: :json
    assert_response :success
    assert_equal Mime::JSON, response.content_type
    assert_equal 1, JSON.parse(response.body).size
  end

  test 'Create spot' do
    login_as_admin
    assert_difference('Spot.count', 1) { post :save, spot: build(:spot).attributes, format: :json }
  end

  test 'Update spot' do
    spot = create(:spot)
    login_as_admin
    assert_difference('Spot.count', 0) { post :save, spot: {id: spot.id, memo: "Zzz"}, format: :json }
  end

  test 'Destroy spot' do
    spot = create(:spot)
    login_as_admin
    assert_difference('Spot.count', -1) { delete :destroy, id: spot.id, format: :json }
    assert_response :success
    assert_equal Mime::JSON, response.content_type
  end

end
