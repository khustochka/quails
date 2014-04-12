# encoding: utf-8
require 'test_helper'

class LociControllerTest < ActionController::TestCase
  setup do
  end

  test "get index" do
    login_as_admin
    get :index
    assert_response :success
    assert_not_nil assigns(:loci)
  end

  test "get new" do
    login_as_admin
    get :new
    assert_response :success
  end

  test "create locus" do
    assert_difference('Locus.count') do
      login_as_admin
      post :create, locus: build(:locus).attributes
    end
    assert_redirected_to edit_locus_path(assigns(:locus))
  end

  test "show locus" do
    login_as_admin
    get :show, id: 'krym'
    assert_response :success
  end

  test "get locus in JSON" do
    login_as_admin
    get :show, id: 'krym', format: :json
    assert_response :success
    assert_equal Mime::JSON, response.content_type
  end

  test "get locus in JSON by id" do
    login_as_admin
    get :show, id: seed('krym').id, format: :json
    assert_response :success
    assert_equal Mime::JSON, response.content_type
  end

  test "get edit" do
    login_as_admin
    get :edit, id: 'mokrets'
    assert_response :success
  end

  test "update locus" do
    locus = seed(:krym)
    locus.name_ru = 'Крымъ'
    login_as_admin
    put :update, id: locus.to_param, locus: locus.attributes
    assert_redirected_to edit_locus_path(assigns(:locus))
  end

  test "destroy locus" do
    assert_difference('Locus.count', -1) do
      login_as_admin
      delete :destroy, id: 'mokrets'
    end

    assert_redirected_to loci_path
  end

  test "show page to order public locations" do
    login_as_admin
    get :public
    assert_response :success
  end

  test "save order properly" do
    new_list = %w(ukraine usa new_york)
    login_as_admin
    post :save_order, format: :json, order: new_list.map {|r| seed(r).id}
    assert_response :success
    assert_equal new_list, Locus.locs_for_lifelist.pluck(:slug)
  end

  # auth tests

  test 'protect index with authentication' do
    assert_raise(ActionController::RoutingError) { get :index }
    #assert_response 404
  end

  test 'protect show with authentication' do
    assert_raise(ActionController::RoutingError) { get :show, id: 'krym' }
    #assert_response 404
  end

  test 'protect new with authentication' do
    assert_raise(ActionController::RoutingError) { get :new }
    #assert_response 404
  end

  test 'protect edit with authentication' do
    assert_raise(ActionController::RoutingError) { get :edit, id: 'krym' }
    #assert_response 404
  end

  test 'protect create with authentication' do
    assert_raise(ActionController::RoutingError) { post :create, locus: build(:locus).attributes }
    #assert_response 404
  end

  test 'protect update with authentication' do
    locus = seed(:krym)
    assert_raise(ActionController::RoutingError) { put :update, id: locus.to_param, locus: locus.attributes }
    #assert_response 404
  end

  test 'protect destroy with authentication' do
    assert_raise(ActionController::RoutingError) { delete :destroy, id: 'krym' }
    #assert_response 404
  end
end
