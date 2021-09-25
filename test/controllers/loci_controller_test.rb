# frozen_string_literal: true

require "test_helper"

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
    assert_difference("Locus.count") do
      login_as_admin
      post :create, params: {locus: attributes_for(:locus)}
    end
    assert_redirected_to edit_locus_path(assigns(:locus))
  end

  test "show locus" do
    login_as_admin
    get :show, params: {id: "brovary"}
    assert_response :success
  end

  test "get locus in JSON" do
    login_as_admin
    get :show, params: {id: "brovary"}, format: :json
    assert_response :success
    assert_equal Mime[:json], response.media_type
  end

  test "get locus in JSON by id" do
    login_as_admin
    get :show, params: {id: loci(:brovary).id}, format: :json
    assert_response :success
    assert_equal Mime[:json], response.media_type
  end

  test "get edit" do
    login_as_admin
    get :edit, params: {id: "brovary"}
    assert_response :success
  end

  test "update locus" do
    locus = loci(:brovary)
    locus.name_ru = "Браворы"
    login_as_admin
    put :update, params: {id: locus.to_param, locus: locus.attributes}
    assert_redirected_to edit_locus_path(assigns(:locus))
  end

  test "destroy locus" do
    assert_difference("Locus.count", -1) do
      login_as_admin
      delete :destroy, params: {id: "brovary"}
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
    post :save_order, params: {order: new_list.map {|r| loci(r).id}}, format: :json
    assert_response :success
    assert_equal new_list, Locus.locs_for_lifelist.pluck(:slug)
  end

  # auth tests

  test "protect index with authentication" do
    assert_raise(ActionController::RoutingError) { get :index }
    # assert_response 404
  end

  test "protect show with authentication" do
    assert_raise(ActionController::RoutingError) { get :show, params: {id: "krym"} }
    # assert_response 404
  end

  test "protect new with authentication" do
    assert_raise(ActionController::RoutingError) { get :new }
    # assert_response 404
  end

  test "protect edit with authentication" do
    assert_raise(ActionController::RoutingError) { get :edit, params: {id: "krym"} }
    # assert_response 404
  end

  test "protect create with authentication" do
    assert_raise(ActionController::RoutingError) { post :create, params: {locus: attributes_for(:locus)} }
    # assert_response 404
  end

  test "protect update with authentication" do
    locus = loci(:brovary)
    assert_raise(ActionController::RoutingError) { put :update, params: {id: locus.to_param, locus: locus.attributes} }
    # assert_response 404
  end

  test "protect destroy with authentication" do
    assert_raise(ActionController::RoutingError) { delete :destroy, params: {id: "krym"} }
    # assert_response 404
  end
end
