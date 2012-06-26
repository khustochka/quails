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

  test "species index properly ordered" do
    # Dummy swap of two species
    max_index = Species.maximum(:index_num)
    sp1 = Species.find_by_index_num(10)
    sp1.update_attributes(index_num: max_index + 1)
    sp2 = Species.find_by_index_num(max_index)
    sp2.update_attributes(index_num: 10)

    get :index
    assert_response :success
    assigns(:species).last.should eq(sp1)
  end

  test "show species" do
    species = seed(:melgal)
    get :show, id: species.to_param
    assert_response :success
  end

  test "get edit" do
    species = seed(:melgal)
    login_as_admin
    get :edit, id: species.to_param
    assert_response :success
  end

  test "update species" do
    species = seed(:corbra)
    species.name_ru = 'Американская ворона'
    login_as_admin
    put :update, id: species.to_param, species: species.attributes
    assert_redirected_to species_path(assigns(:species))
  end

  test "do not update species with invalid name_sci" do
    species = seed(:corbra)
    species2 = species.dup
    old_id = species.to_param
    species2.name_sci = '$!#@'
    login_as_admin
    put :update, id: old_id, species: species2.attributes
    assert_template :form
    assert_select "form[action=#{species_path(species)}]"
  end

  test "redirect species to correct URL " do
    get :show, id: 'Corvus cornix'
    assert_redirected_to species_path(id: 'Corvus_cornix')
    assert_response 301
  end

  # HTTP auth tests

  test 'protect edit with HTTP authentication' do
    species = seed(:melgal)
    expect { get :edit, id: species.to_param }.to raise_error(ActionController::RoutingError)
    #assert_response 404
  end

  test 'protect update with HTTP authentication' do
    species = seed(:corbra)
    species.name_ru = 'Американская ворона'
    expect { put :update, id: species.to_param, species: species.attributes }.to raise_error(ActionController::RoutingError)
    #assert_response 404
  end
end
