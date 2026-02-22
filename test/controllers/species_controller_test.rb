# frozen_string_literal: true

require "test_helper"

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

  test "search species for admin index page" do
    login_as_admin
    get :index, params: { term: "gar", instant_search: 1 }
    assert_response :success
    species = assigns(:species)
    assert_not_nil species
    assert_template "species/_table"
    assert_template layout: false
  end

  test "get gallery" do
    # Setup main image for species
    @image = create(:image)
    assert species(:pasdom).image
    @obs = @image.observations.first

    get :gallery
    assert_response :success
    assert_not_nil assigns(:species)
    assert_select "a[href='#{species_path(@obs.species)}']"
  end

  test "show link to multiple species on gallery" do
    # Setup main image for species
    @image = create(:image)
    assert species(:pasdom).image
    @obs = @image.observations.first

    # Setup photo of several species
    sp1 = taxa(:saxola)
    sp2 = taxa(:jyntor)
    card = create(:card, observ_date: "2008-07-01")
    obs1 = create(:observation, taxon: sp1, card: card)
    obs2 = create(:observation, taxon: sp2, card: card)
    img = create(:image, slug: "picture-of-the-shrike-and-the-wryneck", observations: [obs1, obs2])

    get :gallery
    assert_response :success
    assert_select "a[href='#{photos_multiple_species_path}'] img[src='#{thumbnail_item(img).full_url}']"
  end

  test "species index properly ordered" do
    # Dummy swap of two species
    min_index = Species.minimum(:index_num)
    max_index = Species.maximum(:index_num)
    sp1 = Species.find_by(index_num: min_index)
    sp2 = Species.find_by(index_num: max_index)
    sp1.update!(index_num: max_index)
    sp2.update!(index_num: min_index)

    login_as_admin
    get :index
    assert_response :success
    assert_equal sp1, assigns(:species).last
  end

  test "show species" do
    species = species(:jyntor)
    get :show, params: { id: species.to_param }
    assert_response :success
  end

  test "species with main image correctly rendered to admin" do
    login_as_admin
    im = create(:image)
    species = species(:pasdom)

    get :show, params: { id: species.to_param }
    assert_response :success
  end

  test "show species with image" do
    tx = taxa(:jyntor)
    create(:image, observations: [create(:observation, taxon: tx)])
    get :show, params: { id: tx.species.to_param }
    assert_response :success
  end

  test "main image link should be localized" do
    tx = taxa(:jyntor)
    img = create(:image, observations: [create(:observation, taxon: tx)])
    get :show, params: { id: tx.species.to_param, locale: :en }
    assert_response :success
    assert_select "a[href='/en/photos/#{img.slug}']"
  end

  test "show species with video" do
    tx = taxa(:jyntor)
    create(:video, observations: [create(:observation, taxon: tx)])
    get :show, params: { id: tx.species.to_param }
    assert_response :success
  end

  test "get edit" do
    species = species(:jyntor)
    login_as_admin
    get :edit, params: { id: species.to_param }
    assert_response :success
  end

  test "normal update species should get back to edit form" do
    species = species(:bomgar)
    species.name_ru = "Богемский свиристель"
    login_as_admin
    put :update, params: { id: species.to_param, species: species.attributes }
    assert_redirected_to edit_species_path(assigns(:species))
  end

  test "update species via JSON" do
    species = species(:bomgar)
    login_as_admin
    put :update, params: { id: species.to_param, species: { name_ru: "Богемский свиристель" } }, format: :json
    assert_response :success
    assert_equal Mime[:json], response.media_type
  end

  test "do not update species with invalid name_sci" do
    species = species(:bomgar)
    sp_attr = species.attributes
    old_id = species.to_param
    sp_attr["name_sci"] = '$!#@'
    login_as_admin
    put :update, params: { id: old_id, species: sp_attr }
    assert_template :form
    assert_select "form[action='#{species_path(species)}']"
  end

  test "correct spaces in species URL" do
    get :show, params: { id: "Saxicola rubicola" }
    assert_redirected_to species_path(id: "Saxicola_rubicola")
    assert_response :moved_permanently
  end

  test "redirect old synonym to the new species URL" do
    get :show, params: { id: "Saxicola torquata" }
    assert_redirected_to species_path(id: "Saxicola_rubicola")
    assert_response :moved_permanently
  end

  # auth tests

  test "protect index with authentication" do
    assert_raise(ActionController::RoutingError) { get :index }
    # assert_response 404
  end

  test "protect edit with authentication" do
    species = species(:jyntor)
    assert_raise(ActionController::RoutingError) { get :edit, params: { id: species.to_param } }
    # assert_response 404
  end

  test "protect update with authentication" do
    species = species(:bomgar)
    species.name_ru = "Богемский свиристель"
    assert_raise(ActionController::RoutingError) { put :update, params: { id: species.to_param, species: species.attributes } }
    # assert_response 404
  end

  test "search" do
    create(:observation, taxon: taxa(:bomgar))
    get :search, params: { term: "gar" }, format: :json
    assert_response :success
    assert_equal Mime[:json], response.media_type
    assert_includes response.body, "garrulus"
  end

  test "search localized" do
    create(:observation, taxon: taxa(:bomgar))
    get :search, params: { term: "gar", locale: "en" }, format: :json
    assert_response :success
    assert_equal Mime[:json], response.media_type
    assert_includes response.body, "Waxwing"
    assert_includes response.body, "/en/species/Bombycilla"
  end

  test "search with empty params" do
    get :search, params: {}, format: :json
    assert_response :success
    assert_equal Mime[:json], response.media_type
    assert_equal "[]", response.body
  end
end
