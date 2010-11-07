require 'test_helper'

class SpeciesControllerTest < ActionController::TestCase
  setup do
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:species)
  end

  test "should show species" do
    species = Species.find_by_code!('melgal')
    get :show, :id => species.to_param
    assert_response :success
  end

  test "should get edit" do
    species = Species.find_by_code!('melgal')
    get :edit, :id => species.to_param
    assert_response :success
  end

  test "should update species" do
    species = Species.find_by_code!('corbra')
    species.name_ru = 'Американская ворона'

    put :update, :id => species.to_param, :species => species.attributes
    assert_redirected_to species_path(assigns(:species))
  end
end
