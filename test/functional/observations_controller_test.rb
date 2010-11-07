require 'test_helper'

class ObservationsControllerTest < ActionController::TestCase
  setup do
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:observations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create observation" do
    observation = Factory.build(:observation)
    assert_difference('Observation.count') do
      post :create, :observation => observation.attributes
    end

    assert_redirected_to observation_path(assigns(:observation))
  end

  test "should redirect show observation to edit" do
    observation = Factory.create(:observation)
    get :show, :id => observation.to_param
    assert_redirected_to edit_observation_path(assigns(:observation))
  end

  test "should get edit" do
    observation = Factory.create(:observation)
    get :edit, :id => observation.to_param
    assert_response :success
  end

  test "should update observation" do
    observation = Factory.create(:observation)
    observation.observ_date = '2010-11-07'
    put :update, :id => observation.to_param, :observation => observation.attributes
    assert_redirected_to edit_observation_path(assigns(:observation))
  end

  test "should destroy observation" do
    observation = Factory.create(:observation)
    assert_difference('Observation.count', -1) do
      delete :destroy, :id => observation.to_param
    end

    assert_redirected_to observations_path
  end
end
