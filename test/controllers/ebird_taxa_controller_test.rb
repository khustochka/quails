# frozen_string_literal: true

require "test_helper"

class EBirdTaxaControllerTest < ActionController::TestCase
  test "user does not see the ebird taxa list" do
    assert_raise(ActionController::RoutingError) { get :index }
  end

  test "admin sees the ebird taxa list" do
    login_as_admin
    get :index

    assert_response :success
    assert_includes assigns(:taxa).map(&:ebird_code), "houspa"
  end

  test "the list can be filtered by a search term" do
    login_as_admin
    get :index, params: { term: "House Sparrow" }

    assert_response :success
    assert_equal ["houspa"], assigns(:taxa).map(&:ebird_code)
  end

  test "instant search renders the table without a layout" do
    login_as_admin
    get :index, params: { term: "House Sparrow", instant_search: true }

    assert_response :success
    assert_template partial: "ebird_taxa/_table"
    assert_template layout: false
  end

  test "admin sees a single ebird taxon" do
    login_as_admin
    get :show, params: { id: "houspa" }

    assert_response :success
    assert_equal ebird_taxa(:pasdom), assigns(:taxon)
  end

  test "promote creates the taxon and redirects to it" do
    login_as_admin
    ebird_taxon = ebird_taxa(:some_species)
    assert_nil ebird_taxon.taxon

    assert_difference -> { Taxon.count }, 1 do
      post :promote, params: { id: "soltin1" }
    end

    assert_redirected_to ebird_taxon_path(ebird_taxon)
    assert_equal "Tinamus solitarius", ebird_taxon.reload.taxon.name_sci
  end

  test "promote of an already promoted taxon does not create another one" do
    login_as_admin

    assert_no_difference -> { Taxon.count } do
      post :promote, params: { id: "houspa" }
    end

    assert_redirected_to ebird_taxon_path(ebird_taxa(:pasdom))
  end
end
