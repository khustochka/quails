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

  test "index links slug to show page with a separate edit link" do
    login_as_admin
    get :index
    assert_response :success
    assert_select "a[href=?]", locus_path(loci(:brovary)), text: "brovary"
    assert_select "a.pseudolink[href=?]", edit_locus_path(loci(:brovary)), text: "edit"
  end

  test "get new" do
    login_as_admin
    get :new
    assert_response :success
  end

  test "create locus" do
    assert_difference("Locus.count") do
      login_as_admin
      post :create, params: { locus: attributes_for(:locus) }
    end
    assert_redirected_to edit_locus_path(assigns(:locus))
  end

  test "show locus" do
    login_as_admin
    get :show, params: { id: "brovary" }
    assert_response :success
  end

  test "show locus lists parent link, breadcrumb and children" do
    login_as_admin
    get :show, params: { id: "kiev_obl" }
    assert_response :success
    # Parent link in the details table
    assert_select "table.locus-details a[href=?]", locus_path(loci(:ukraine)), text: "Ukraine"
    # Breadcrumb to ancestors
    assert_select "nav.locus-breadcrumb a[href=?]", locus_path(loci(:ukraine)), text: "Ukraine"
    # Children list
    assert_select "ul.locus-children" do
      assert_select "a[href=?]", locus_path(loci(:brovary)), text: "Brovary"
      assert_select "a[href=?]", locus_path(loci(:kyiv)), text: "Kyiv City"
    end
    assert_select "ul.admin-shortcuts a[href=?][target=_blank]",
      advanced_list_path(locus: "kiev_obl"), text: "Lifelist"
  end

  test "show locus links coordinates to Google Maps" do
    login_as_admin
    get :show, params: { id: "brovary" }
    assert_response :success
    locus = loci(:brovary)
    assert_select "a[href=?]", "https://www.google.com/maps?q=#{locus.lat},#{locus.lon}",
      text: "50.5100;30.7900"
  end

  test "show locus with no children shows empty message" do
    login_as_admin
    get :show, params: { id: "brovary" }
    assert_response :success
    assert_select "ul.locus-children", count: 0
    assert_select ".empty", text: "No children."
  end

  test "get locus in JSON" do
    login_as_admin
    get :show, params: { id: "brovary" }, format: :json
    assert_response :success
    assert_equal Mime[:json], response.media_type
  end

  test "get locus in JSON by id" do
    login_as_admin
    get :show, params: { id: loci(:brovary).id }, format: :json
    assert_response :success
    assert_equal Mime[:json], response.media_type
  end

  test "get edit" do
    login_as_admin
    get :edit, params: { id: "brovary" }
    assert_response :success
  end

  test "edit shows ancestry list with edit links and loc_type badges" do
    login_as_admin
    get :edit, params: { id: "brovary" }
    assert_response :success
    assert_select "ul.locus-ancestry" do
      assert_select "a[href=?]", edit_locus_path(loci(:ukraine)), text: "Ukraine"
      assert_select "a[href=?]", edit_locus_path(loci(:kiev_obl)), text: "Kyiv oblast"
      assert_select "span.tag", text: "country"
      assert_select "span.tag", text: "subdivision1"
    end
  end

  test "update locus" do
    locus = loci(:brovary)
    locus.name_ru = "Браворы"
    login_as_admin
    put :update, params: { id: locus.to_param, locus: locus.attributes }
    assert_redirected_to edit_locus_path(assigns(:locus))
  end

  test "destroy locus" do
    assert_difference("Locus.count", -1) do
      login_as_admin
      delete :destroy, params: { id: "brovary" }
    end

    assert_redirected_to loci_path
  end

  test "promote_children re-parents children to the parent and redirects to show" do
    login_as_admin
    ukraine = loci(:ukraine)
    post :promote_children, params: { id: "kiev_obl" }
    assert_redirected_to locus_path(loci(:kiev_obl))
    assert_equal ukraine, loci(:brovary).reload.parent
    assert_equal ukraine, loci(:kyiv).reload.parent
    assert_empty loci(:kiev_obl).reload.children
  end

  test "show page shows public full name when public locus differs from self" do
    login_as_admin
    private_locus = create(:locus, parent: loci(:brovary), private_loc: true)
    get :show, params: { id: private_locus.to_param }
    assert_response :success
    assert_select "table.locus-details th", text: "Public full name"
    assert_select "table.locus-details td", text: private_locus.public_locus.decorated.full_name
  end

  test "show page omits public full name when locus is its own public locus" do
    login_as_admin
    get :show, params: { id: "brovary" }
    assert_response :success
    assert_select "table.locus-details th", text: "Public full name", count: 0
  end

  test "show page renders promote-children button when there are children" do
    login_as_admin
    get :show, params: { id: "kiev_obl" }
    assert_response :success
    assert_select "form[action=?]", promote_children_locus_path(loci(:kiev_obl)) do
      assert_select "button", text: /Promote children/
    end
  end

  test "show page hides promote-children button when there are no children" do
    login_as_admin
    get :show, params: { id: "brovary" }
    assert_response :success
    assert_select "form[action=?]", promote_children_locus_path(loci(:brovary)), count: 0
  end

  test "show page to order public locations" do
    login_as_admin
    get :public
    assert_response :success
  end

  test "public lists typed loci but excludes site and section" do
    typed = create(:locus, slug: "krym", name_en: "Krym", parent: loci(:ukraine), loc_type: "subdivision1")
    site = create(:locus, slug: "some_park", name_en: "Some Park", parent: loci(:ukraine), loc_type: "site")
    section = create(:locus, slug: "some_trail", name_en: "Some Trail", parent: loci(:ukraine), loc_type: "section")

    login_as_admin
    get :public
    assert_response :success

    other_ids = assigns(:locs_other).map(&:id)
    assert_includes other_ids, typed.id
    assert_not_includes other_ids, site.id
    assert_not_includes other_ids, section.id
  end

  test "save order properly" do
    new_list = %w(ukraine usa new_york)
    login_as_admin
    post :save_order, params: { order: new_list.map {|r| loci(r).id} }, format: :json
    assert_response :success
    assert_equal new_list, Locus.locs_for_lifelist.pluck(:slug)
  end

  # auth tests

  test "protect index with authentication" do
    assert_raise(ActionController::RoutingError) { get :index }
    # assert_response 404
  end

  test "protect show with authentication" do
    assert_raise(ActionController::RoutingError) { get :show, params: { id: "krym" } }
    # assert_response 404
  end

  test "protect new with authentication" do
    assert_raise(ActionController::RoutingError) { get :new }
    # assert_response 404
  end

  test "protect edit with authentication" do
    assert_raise(ActionController::RoutingError) { get :edit, params: { id: "krym" } }
    # assert_response 404
  end

  test "protect create with authentication" do
    assert_raise(ActionController::RoutingError) { post :create, params: { locus: attributes_for(:locus) } }
    # assert_response 404
  end

  test "protect update with authentication" do
    locus = loci(:brovary)
    assert_raise(ActionController::RoutingError) { put :update, params: { id: locus.to_param, locus: locus.attributes } }
    # assert_response 404
  end

  test "protect destroy with authentication" do
    assert_raise(ActionController::RoutingError) { delete :destroy, params: { id: "krym" } }
    # assert_response 404
  end

  test "protect promote_children with authentication" do
    assert_raise(ActionController::RoutingError) { post :promote_children, params: { id: "kiev_obl" } }
    # assert_response 404
  end
end
