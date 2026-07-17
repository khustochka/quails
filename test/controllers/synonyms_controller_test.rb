# frozen_string_literal: true

require "test_helper"

class SynonymsControllerTest < ActionController::TestCase
  test "user does not see the synonyms page" do
    assert_raise(ActionController::RoutingError) { get :index }
  end

  test "admin sees the synonyms page" do
    login_as_admin
    get :index

    assert_response :success
    assert_includes assigns(:synonyms), url_synonyms(:stomechat)
  end

  test "the page shows the old name and the species it redirects to" do
    login_as_admin
    get :index

    assert_response :success
    assert_select "td", text: /Saxicola torquata/
    assert_select "td", text: /Saxicola rubicola/
  end

  test "synonyms are ordered by scientific name" do
    UrlSynonym.create!(name_sci: "Anas boschas", species: species(:pasdom))

    login_as_admin
    get :index

    assert_response :success
    names = assigns(:synonyms).map(&:name_sci)
    assert_equal names.sort, names
  end

  test "admin can set the reason of a synonym" do
    synonym = url_synonyms(:stomechat)
    login_as_admin

    patch :update, params: { id: synonym.id, url_synonym: { reason: "split" } }

    assert_equal "split", synonym.reload.reason
  end
end
