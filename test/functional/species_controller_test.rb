# encoding: utf-8
require 'test_helper'

class SpeciesControllerTest < ActionController::TestCase

  include ImagesHelper

  setup do
  end

  test "get index" do
    login_as_admin
    get :index
    assert_response :success
    assert_not_nil assigns(:species)
  end

  test "get gallery" do
    # Setup main image for species
    @image = create(:image)
    seed(:pasdom).update_column(:image_id, @image.id)
    @obs = @image.observations.first

    get :gallery
    assert_response :success
    assert_not_nil assigns(:species)
    assert_select "a[href=#{species_path(@obs.species)}]"
  end

  test "show link to multiple species on gallery" do
    # Setup main image for species
    @image = create(:image)
    seed(:pasdom).update_column(:image_id, @image.id)
    @obs = @image.observations.first

    # Setup photo of several species
    sp1 = seed(:lancol)
    sp2 = seed(:jyntor)
    card = create(:card, observ_date: "2008-07-01")
    obs1 = create(:observation, species: sp1, card: card)
    obs2 = create(:observation, species: sp2, card: card)
    img = create(:image, slug: 'picture-of-the-shrike-and-the-wryneck', observations: [obs1, obs2])

    get :gallery
    assert_response :success
    assert_not_nil assigns(:thumbnail_for_multiple_species)
    assert_select "a[href=#{photos_multiple_species_path}] img[src=#{thumbnail_url(img)}]"
  end

  test "species index properly ordered" do
    # Dummy swap of two species
    max_index = Species.maximum(:index_num)
    sp1 = Species.find_by_index_num(10)
    sp1.update_attributes(index_num: max_index + 1)
    sp2 = Species.find_by_index_num(max_index)
    sp2.update_attributes(index_num: 10)

    login_as_admin
    get :index
    assert_response :success
    assert_equal sp1, assigns(:species).last
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

  test "update species via JSON" do
    species = seed(:corbra)
    login_as_admin
    put :update, id: species.to_param, species: {name_ru: 'Американская ворона'}, format: :json
    assert_response :success
    assert_equal Mime::JSON, response.content_type
  end

  test "do not update species with invalid name_sci" do
    species = seed(:corbra)
    sp_attr = species.attributes
    old_id = species.to_param
    sp_attr['name_sci'] = '$!#@'
    login_as_admin
    put :update, id: old_id, species: sp_attr
    assert_template :form
    assert_select "form[action=#{species_path(species)}]"
  end

  test "redirect species to correct URL " do
    get :show, id: 'Corvus cornix'
    assert_redirected_to species_path(id: 'Corvus_cornix')
    assert_response 301
  end

  # HTTP auth tests

  test 'protect index with HTTP authentication' do
    assert_raise(ActionController::RoutingError) { get :index }
    #assert_response 404
  end

  test 'protect edit with HTTP authentication' do
    species = seed(:melgal)
    assert_raise(ActionController::RoutingError) { get :edit, id: species.to_param }
    #assert_response 404
  end

  test 'protect update with HTTP authentication' do
    species = seed(:corbra)
    species.name_ru = 'Американская ворона'
    assert_raise(ActionController::RoutingError) { put :update, id: species.to_param, species: species.attributes }
    #assert_response 404
  end
end
