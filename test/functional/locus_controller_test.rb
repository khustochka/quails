require 'test_helper'

class LocusControllerTest < ActionController::TestCase
  setup do
    @locus = locus(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:locus)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create locus" do
    assert_difference('Locus.count') do
      post :create, :locus => @locus.attributes
    end

    assert_redirected_to locus_path(assigns(:locus))
  end

  test "should show locus" do
    get :show, :id => @locus.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @locus.to_param
    assert_response :success
  end

  test "should update locus" do
    put :update, :id => @locus.to_param, :locus => @locus.attributes
    assert_redirected_to locus_path(assigns(:locus))
  end

  test "should destroy locus" do
    assert_difference('Locus.count', -1) do
      delete :destroy, :id => @locus.to_param
    end

    assert_redirected_to locus_index_path
  end
end
