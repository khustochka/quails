# frozen_string_literal: true

require "test_helper"

class Reports::FiveMileRadiusControllerTest < ActionController::TestCase
  # The test environment uses a null store, so the candidates written by the 5MR job are
  # never read back. Swap in a real store to exercise the action.
  def with_cached_candidates(candidates: [], removal: [])
    original = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    Rails.cache.write("5mr/candidates", candidates)
    Rails.cache.write("5mr/removal", removal)
    yield
  ensure
    Rails.cache = original
  end

  test "user does not see the 5MR report" do
    assert_raise(ActionController::RoutingError) { get :index }
  end

  test "admin sees an empty report when nothing is cached" do
    login_as_admin
    get :index

    assert_response :success
    assert_empty assigns(:candidates_5mr)
    assert_empty assigns(:candidates_removal)
  end

  test "candidates already inside the 5MR are not offered for adding" do
    inside = create(:locus, five_mile_radius: true)
    outside = create(:locus, five_mile_radius: false)

    login_as_admin
    with_cached_candidates(candidates: [{ locus_id: inside.id, distance: 1.0 },
      { locus_id: outside.id, distance: 2.0 },]) do
      get :index
    end

    assert_response :success
    assert_equal [outside.id], assigns(:candidates_5mr).pluck(:locus_id)
  end

  test "only loci already inside the 5MR are offered for removal" do
    inside = create(:locus, five_mile_radius: true)
    outside = create(:locus, five_mile_radius: false)

    login_as_admin
    with_cached_candidates(removal: [{ locus_id: inside.id, distance: 9.0 },
      { locus_id: outside.id, distance: 8.0 },]) do
      get :index
    end

    assert_response :success
    assert_equal [inside.id], assigns(:candidates_removal).pluck(:locus_id)
  end

  test "candidates are sorted by distance and carry their locus" do
    near = create(:locus, five_mile_radius: false)
    far = create(:locus, five_mile_radius: false)

    login_as_admin
    with_cached_candidates(candidates: [{ locus_id: far.id, distance: 4.5 },
      { locus_id: near.id, distance: 1.5 },]) do
      get :index
    end

    assert_response :success
    assert_equal [near.id, far.id], assigns(:candidates_5mr).pluck(:locus_id)
    assert_equal [near, far], assigns(:candidates_5mr).pluck(:locus)
  end

  test "Confirm adds the selected loci to the 5MR" do
    locus = create(:locus, five_mile_radius: false)

    login_as_admin
    post :update, params: { locus_id: [locus.id], commit: "Confirm" }

    assert_redirected_to reports_five_mile_radius_path
    assert_predicate locus.reload, :five_mile_radius?
  end

  test "Remove takes the selected loci out of the 5MR" do
    locus = create(:locus, five_mile_radius: true)

    login_as_admin
    post :update, params: { locus_id: [locus.id], commit: "Remove" }

    assert_redirected_to reports_five_mile_radius_path
    assert_not_predicate locus.reload, :five_mile_radius?
  end

  test "an unknown commit action is rejected" do
    locus = create(:locus, five_mile_radius: false)

    login_as_admin
    assert_raise(RuntimeError) { post :update, params: { locus_id: [locus.id], commit: "Whatever" } }

    assert_not_predicate locus.reload, :five_mile_radius?
  end
end
