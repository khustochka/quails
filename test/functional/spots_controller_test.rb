require 'test_helper'

class SpotsControllerTest < ActionController::TestCase

  test "returns spots" do
    obs1 = create(:observation, card: create(:card, observ_date: '2010-07-24'))
    obs2 = create(:observation, card: create(:card, observ_date: '2011-07-24'))
    create(:spot, observation: obs1)
    create(:spot, observation: obs2)
    login_as_admin
    get :index, format: :json
    assert_response :success
    assert_equal Mime::JSON, response.content_type
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
