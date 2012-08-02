# encoding: utf-8
require 'test_helper'

class LociControllerTest < ActionController::TestCase
  setup do
  end

  test "get index" do
    login_as_admin
    get :index
    assert_response :success
    assert_not_nil assigns(:locus_by_type)
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
    assert_redirected_to locus_path(assigns(:locus))
  end

  test "show locus" do
    login_as_admin
    get :show, id: 'krym'
    assert_response :success
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
    assert_redirected_to locus_path(assigns(:locus))
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

  # HTTP auth tests

  test 'protect index with HTTP authentication' do
    expect { get :index }.to raise_error(ActionController::RoutingError)
    #assert_response 404
  end

  test 'protect show with HTTP authentication' do
    expect { get :show, id: 'krym' }.to raise_error(ActionController::RoutingError)
    #assert_response 404
  end

  test 'protect new with HTTP authentication' do
    expect { get :new }.to raise_error(ActionController::RoutingError)
    #assert_response 404
  end

  test 'protect edit with HTTP authentication' do
    expect { get :edit, id: 'krym' }.to raise_error(ActionController::RoutingError)
    #assert_response 404
  end

  test 'protect create with HTTP authentication' do
    expect { post :create, locus: build(:locus).attributes }.to raise_error(ActionController::RoutingError)
    #assert_response 404
  end

  test 'protect update with HTTP authentication' do
    locus = seed(:krym)
    expect { put :update, id: locus.to_param, locus: locus.attributes }.to raise_error(ActionController::RoutingError)
    #assert_response 404
  end

  test 'protect destroy with HTTP authentication' do
    expect { delete :destroy, id: 'krym' }.to raise_error(ActionController::RoutingError)
    #assert_response 404
  end
end
