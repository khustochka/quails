# encoding: utf-8
require 'test_helper'

class SpeciesControllerTest < ActionController::TestCase
  setup do
  end

  should "get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:species)
  end

  should "show species" do
    species = Species.find_by_code!('melgal')
    get :show, :id => species.to_param
    assert_response :success
  end

  should "get edit" do
    species = Species.find_by_code!('melgal')
    login_as_admin
    get :edit, :id => species.to_param
    assert_response :success
  end

  should "update species" do
    species = Species.find_by_code!('corbra')
    species.name_ru = 'Американская ворона'
    login_as_admin
    put :update, :id => species.to_param, :species => species.attributes
    assert_redirected_to species_path(assigns(:species))
  end

  # HTTP auth tests

  should 'protect edit with HTTP authentication' do
    species = Species.find_by_code!('melgal')
    get :edit, :id => species.to_param
    assert_response 401
  end

  should 'protect update with HTTP authentication' do
    species = Species.find_by_code!('corbra')
    species.name_ru = 'Американская ворона'
    put :update, :id => species.to_param, :species => species.attributes
    assert_response 401
  end
end
