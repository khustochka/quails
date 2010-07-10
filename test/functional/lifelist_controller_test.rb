require 'test_helper'

class LifelistControllerTest < ActionController::TestCase
  setup do
    @lifelist = lifelists(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:lifelists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create lifelist" do
    assert_difference('Lifelist.count') do
      post :create, :lifelist => @lifelist.attributes
    end

    assert_redirected_to lifelist_path(assigns(:lifelist))
  end

  test "should show lifelist" do
    get :show, :id => @lifelist.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @lifelist.to_param
    assert_response :success
  end

  test "should update lifelist" do
    put :update, :id => @lifelist.to_param, :lifelist => @lifelist.attributes
    assert_redirected_to lifelist_path(assigns(:lifelist))
  end

  test "should destroy lifelist" do
    assert_difference('Lifelist.count', -1) do
      delete :destroy, :id => @lifelist.to_param
    end

    assert_redirected_to lifelists_path
  end
end
