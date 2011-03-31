# encoding: utf-8
require 'test_helper'

class LocusControllerTest < ActionController::TestCase
  setup do
  end

  should "get index" do
    login_as_admin
    get :index
    assert_response :success
    assert_not_nil assigns(:locus)
  end

  should "get new" do
    login_as_admin
    get :new
    assert_response :success
  end

  should "create locus" do
    locus = Factory.build(:locus, :code => 'loccode', :loc_type => 'Country')
    assert_difference('Locus.count') do
      login_as_admin
      post :create, :locus => locus.attributes
    end

    assert_redirected_to locus_path(assigns(:locus))
  end

  should "show locus" do
    login_as_admin
    get :show, :id => 'krym'
    assert_response :success
  end

  should "get edit" do
    login_as_admin
    get :edit, :id => 'mokrets'
    assert_response :success
  end

  should "update locus" do
    locus         = Locus.find_by_code!('krym')
    locus.name_ru = 'Крымъ'
    login_as_admin
    put :update, :id => locus.to_param, :locus => locus.attributes
    assert_redirected_to locus_path(assigns(:locus))
  end

  should "destroy locus" do
    assert_difference('Locus.count', -1) do
      login_as_admin
      delete :destroy, :id => 'mokrets'
    end

    assert_redirected_to locus_index_path
  end

  # HTTP auth tests

  should 'protect index with HTTP authentication' do
    get :index
    assert_response 401
  end

  should 'protect show with HTTP authentication' do
    get :show, :id => 'krym'
    assert_response 401
  end

  should 'protect new with HTTP authentication' do
    get :new
    assert_response 401
  end

  should 'protect edit with HTTP authentication' do
    get :edit, :id => 'krym'
    assert_response 401
  end

  should 'protect create with HTTP authentication' do
    locus = Factory.build(:locus, :code => 'loccode', :loc_type => 'Country')
    post :create, :locus => locus.attributes
    assert_response 401
  end

  should 'protect update with HTTP authentication' do
    locus = Locus.find_by_code!('krym')
    put :update, :id => locus.to_param, :locus => locus.attributes
    assert_response 401
  end

  should 'protect destroy with HTTP authentication' do
    delete :destroy, :id => 'krym'
    assert_response 401
  end
end
