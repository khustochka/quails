# encoding: utf-8
require 'test_helper'

class SpeciesControllerTest < ActionController::TestCase
  setup do
  end

  test "get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:species)
  end

  test "show species" do
    species = seed(:melgal)
    get :show, :id => species.to_param
    assert_response :success
  end

  test "get edit" do
    species = seed(:melgal)
    login_as_admin
    get :edit, :id => species.to_param
    assert_response :success
  end

  test "update species" do
    species = seed(:corbra)
    species.name_ru = 'Американская ворона'
    login_as_admin
    put :update, :id => species.to_param, :species => species.attributes
    assert_redirected_to species_path(assigns(:species))
  end

  test "do not update species with invalid name_sci" do
    species = seed(:corbra)
    species2 = species.dup
    old_id = species.to_param
    species2.name_sci = '$!#@'
    login_as_admin
    put :update, :id => old_id, :species => species2.attributes
    assert_template :form
    assert_select "form[action=#{species_path(species)}]"
  end

  # HTTP auth tests

  test 'protect edit with HTTP authentication' do
    species = seed(:melgal)
    get :edit, :id => species.to_param
    assert_response 401
  end

  test 'protect update with HTTP authentication' do
    species = seed(:corbra)
    species.name_ru = 'Американская ворона'
    put :update, :id => species.to_param, :species => species.attributes
    assert_response 401
  end
end
