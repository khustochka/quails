# frozen_string_literal: true

require "test_helper"
require "ebird/checklist_meta"

class EBird::ImportsControllerTest < ActionController::TestCase
  # The index action only reads the preloaded checklists out of the cache, so it does not
  # talk to eBird. The test environment uses a null store, so swap in a real one to fill it.
  def with_cached_preload(checklists:, last_preload: Time.zone.now)
    original = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    Rails.cache.write("ebird/preloaded_checklists", checklists)
    Rails.cache.write("ebird/last_preload", last_preload)
    yield
  ensure
    Rails.cache = original
  end

  def checklist_meta(ebird_id: "S108423956", location: "Cordite Trail", card: nil)
    EBird::ChecklistMeta.new(
      ebird_id: ebird_id,
      time: "29 Apr 2022 6:27 PM",
      location: location,
      county: "Winnipeg",
      state_prov: "Manitoba",
      card: card
    )
  end

  test "user does not see the imports page" do
    assert_raise(ActionController::RoutingError) { get :index }
  end

  test "admin sees the imports page when nothing is preloaded" do
    login_as_admin
    get :index

    assert_response :success
    assert_nil assigns(:checklists)
    assert_nil assigns(:last_preload)
  end

  test "admin sees the preloaded checklists" do
    login_as_admin
    with_cached_preload(checklists: [checklist_meta]) do
      get :index
    end

    assert_response :success
    assert_equal ["S108423956"], assigns(:checklists).map(&:ebird_id)
    assert_not_nil assigns(:last_preload)
  end

  test "the newest preloaded checklist is shown first" do
    login_as_admin
    with_cached_preload(checklists: [checklist_meta(ebird_id: "S1"), checklist_meta(ebird_id: "S2")]) do
      get :index
    end

    assert_response :success
    assert_equal %w(S2 S1), assigns(:checklists).map(&:ebird_id)
  end

  test "the page renders a locus select for a checklist that has no card yet" do
    create(:locus, name_en: "Cordite Trail")

    login_as_admin
    with_cached_preload(checklists: [checklist_meta]) do
      get :index
    end

    assert_response :success
    assert_select "select.locus_select"
    assert_select "input[name=?]", "c[][ebird_id]"
  end

  test "the page links to the card of an already imported checklist" do
    card = create(:card)

    login_as_admin
    with_cached_preload(checklists: [checklist_meta(card: card)]) do
      get :index
    end

    assert_response :success
    assert_select "select.locus_select", false
    assert_select "a[href=?]", card_path(card)
  end
end
