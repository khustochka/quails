# frozen_string_literal: true

require 'test_helper'

class SpotsControllerTest < ActionController::TestCase

  test 'Create spot' do
    login_as_admin
    assert_difference('Spot.count', 1) { post :save, params: {spot: attributes_for(:spot, observation_id: create(:observation).id)}, format: :json }
  end

  test 'Update spot' do
    spot = create(:spot)
    login_as_admin
    assert_difference('Spot.count', 0) { post :save, params: {spot: {id: spot.id, memo: "Zzz"}}, format: :json }
  end

  test 'Destroy spot' do
    spot = create(:spot)
    login_as_admin
    assert_difference('Spot.count', -1) { delete :destroy, params: {id: spot.id}, format: :json }
    assert_response :success
    assert_equal Mime[:json], response.media_type
  end

end
