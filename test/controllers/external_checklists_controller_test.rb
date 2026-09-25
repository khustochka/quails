# frozen_string_literal: true

require "test_helper"

class ExternalChecklistsControllerTest < ActionController::TestCase
  test "user does not see the review page" do
    assert_raise(ActionController::RoutingError) { get :index }
  end

  test "admin sees unimported checklists, newest first" do
    old = create(:external_checklist)
    failed = create(:external_checklist, status: "failed", error: "Boom")
    create(:external_checklist, status: "imported")

    login_as_admin
    get :index

    assert_response :success
    assert_equal [failed, old], assigns(:checklists).to_a
    assert_select "select.locus_select", 2
    assert_select "td", text: /Boom/
  end

  test "admin sees a message when there is nothing to review" do
    login_as_admin
    get :index

    assert_response :success
    assert_select "form[action=?]", bulk_update_external_checklists_path, false
    assert_select "p", "No checklists to review."
  end

  test "locus select preselects saved locus over suggested one" do
    create(:locus, name_en: "Cordite Trail")
    saved = Locus.find_by!(slug: "brovary")
    create(:external_checklist, location: "Cordite Trail", locus: saved)

    login_as_admin
    get :index

    assert_select "select.locus_select option[selected][value=?]", saved.id.to_s
  end

  test "locus select preselects suggested locus" do
    suggested = create(:locus, name_en: "Cordite Trail")
    create(:external_checklist, location: "Cordite Trail")

    login_as_admin
    get :index

    assert_select "select.locus_select option[selected][value=?]", suggested.id.to_s
  end

  test "admin saves selected loci" do
    locus = Locus.find_by!(slug: "brovary")
    to_set = create(:external_checklist)
    to_clear = create(:external_checklist, locus: locus)
    imported = create(:external_checklist, status: "imported")

    login_as_admin
    patch :bulk_update, params: { c: {
      to_set.id => { locus_id: locus.id },
      to_clear.id => { locus_id: "" },
      imported.id => { locus_id: locus.id },
    } }

    assert_redirected_to external_checklists_path
    assert_equal locus, to_set.reload.locus
    assert_nil to_clear.reload.locus
    assert_nil imported.reload.locus
  end

  test "user cannot save loci" do
    checklist = create(:external_checklist)

    assert_raise(ActionController::RoutingError) do
      patch :bulk_update, params: { c: { checklist.id => { locus_id: Locus.find_by!(slug: "brovary").id } } }
    end
    assert_nil checklist.reload.locus
  end

  def with_birdnik_url(url = "http://birdnik.test")
    original = ENV["BIRDNIK_API_URL"]
    ENV["BIRDNIK_API_URL"] = url
    yield
  ensure
    ENV["BIRDNIK_API_URL"] = original
  end

  test "admin requests preload with API callback url" do
    stub = stub_request(:post, "http://birdnik.test/preloads")
      .with(body: { callback_url: api_external_checklists_url }.to_json).to_return(status: 202)

    login_as_admin
    with_birdnik_url { post :preload, xhr: true }

    assert_response :accepted
    assert_requested stub
  end

  test "preload reports Birdnik failure" do
    stub_request(:post, "http://birdnik.test/preloads").to_return(status: 503)

    login_as_admin
    with_birdnik_url { post :preload, xhr: true }

    assert_response :bad_gateway
    assert_equal "Birdnik responded with 503.", response.parsed_body["message"]
  end

  test "preload reports missing configuration" do
    login_as_admin
    with_birdnik_url(nil) { post :preload, xhr: true }

    assert_response :bad_gateway
  end

  test "preload without JS redirects back with notice" do
    stub_request(:post, "http://birdnik.test/preloads").to_return(status: 202)

    login_as_admin
    with_birdnik_url { post :preload }

    assert_redirected_to external_checklists_path
    assert_equal "Preload requested.", flash[:notice]
  end

  test "user cannot request preload" do
    assert_raise(ActionController::RoutingError) { post :preload }
  end
end
