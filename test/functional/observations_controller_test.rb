require 'test_helper'

class ObservationsControllerTest < ActionController::TestCase
  setup do
    @observation = observations(:one)
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
    assert_difference('Observation.count') do
      post :create, :observation => @observation.attributes
    end

    assert_redirected_to observation_path(assigns(:observation))
  end

  test "should show observation" do
    get :show, :id => @observation.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @observation.to_param
    assert_response :success
  end

  test "should update observation" do
    put :update, :id => @observation.to_param, :observation => @observation.attributes
    assert_redirected_to observation_path(assigns(:observation))
  end

  test "should destroy observation" do
    assert_difference('Observation.count', -1) do
      delete :destroy, :id => @observation.to_param
    end

    assert_redirected_to observations_path
  end
end
