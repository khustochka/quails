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
    assert_select "form[action=?]", import_external_checklists_path, false
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

  test "import saves selected loci and requests checklists with locus" do
    locus = Locus.find_by!(slug: "brovary")
    to_set = create(:external_checklist)
    to_clear = create(:external_checklist, locus: locus)
    imported = create(:external_checklist, status: "imported")

    stub = stub_request(:post, "http://birdnik.test/fetches")
      .with(body: { external_ids: [to_set.external_id], callback_url: import_api_external_checklists_url }.to_json)
      .to_return(status: 202)

    login_as_admin
    with_birdnik_url do
      post :import, params: { c: {
        to_set.id => { locus_id: locus.id },
        to_clear.id => { locus_id: "" },
        imported.id => { locus_id: locus.id },
      } }
    end

    assert_redirected_to external_checklists_path
    assert_equal "Import of 1 checklists requested.", flash[:notice]
    assert_requested stub
    assert_equal locus, to_set.reload.locus
    assert_predicate to_set, :requested?
    assert_nil to_clear.reload.locus
    assert_predicate to_clear, :pending?
    assert_nil imported.reload.locus
  end

  test "import without any locus does not call Birdnik" do
    checklist = create(:external_checklist)

    login_as_admin
    post :import, params: { c: { checklist.id => { locus_id: "" } } }

    assert_redirected_to external_checklists_path
    assert_equal "No checklists with a locus to import.", flash[:notice]
    assert_predicate checklist.reload, :pending?
  end

  test "import reports Birdnik failure" do
    checklist = create(:external_checklist, locus: Locus.find_by!(slug: "brovary"))
    stub_request(:post, "http://birdnik.test/fetches").to_return(status: 503)

    login_as_admin
    with_birdnik_url { post :import }

    assert_redirected_to external_checklists_path
    assert_equal "Import request failed: Birdnik responded with 503.", flash[:alert]
    assert_predicate checklist.reload, :failed?
  end

  test "user cannot import" do
    checklist = create(:external_checklist)

    assert_raise(ActionController::RoutingError) do
      post :import, params: { c: { checklist.id => { locus_id: Locus.find_by!(slug: "brovary").id } } }
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

  test "rows are marked for live status updates" do
    checklist = create(:external_checklist)

    login_as_admin
    get :index

    assert_select "form[data-external-checklists-import]"
    assert_select "tr[data-external-checklist-id=?]", checklist.id.to_s do
      assert_select "td[data-external-checklist-status] .checklist-status-pending", "pending" do
        assert_select ".fas.fa-clock[aria-hidden=true]"
      end
      assert_select "td[data-external-checklist-locus] select.locus_select"
    end
  end

  test "import via XHR responds with message" do
    create(:external_checklist, locus: Locus.find_by!(slug: "brovary"))
    stub_request(:post, "http://birdnik.test/fetches").to_return(status: 202)

    login_as_admin
    with_birdnik_url { post :import, xhr: true }

    assert_response :success
    assert_equal "Import of 1 checklists requested.", response.parsed_body["message"]
  end

  test "failed import via XHR responds with error" do
    create(:external_checklist, locus: Locus.find_by!(slug: "brovary"))
    stub_request(:post, "http://birdnik.test/fetches").to_return(status: 503)

    login_as_admin
    with_birdnik_url { post :import, xhr: true }

    assert_response :bad_gateway
    assert_equal "Import request failed: Birdnik responded with 503.", response.parsed_body["message"]
  end

  test "import permits only locus selections" do
    checklist = create(:external_checklist)
    original = ActionController::Parameters.action_on_unpermitted_parameters
    ActionController::Parameters.action_on_unpermitted_parameters = :raise

    login_as_admin
    post :import, params: { commit: "Import", authenticity_token: "token", c: { checklist.id => { locus_id: "" } } }

    assert_redirected_to external_checklists_path
  ensure
    ActionController::Parameters.action_on_unpermitted_parameters = original
  end

  test "shows when checklists were never preloaded" do
    login_as_admin
    get :index

    assert_select "p", /Last preloaded at:\s+never/
  end

  test "shows last preload time" do
    original = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    time = Time.zone.parse("2026-09-24 07:15")
    travel_to(time) { ExternalChecklist.record_preload }

    login_as_admin
    get :index

    assert_select "p", /Last preloaded at:\s+#{Regexp.escape(time.to_s)}/
  ensure
    Rails.cache = original
  end
end
