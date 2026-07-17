# frozen_string_literal: true

require "test_helper"

class LifelistBasicTest < ActionController::TestCase
  tests LifelistController

  setup do
    @obs = [
      create(:observation, taxon: taxa(:pasdom), card: create(:card, observ_date: "2010-06-20", locus: loci(:nyc))),
      create(:observation, taxon: taxa(:jyntor), card: create(:card, observ_date: "2010-06-18", locus: loci(:nyc))),
      create(:observation, taxon: taxa(:bomgar), card: create(:card, observ_date: "2009-06-18", locus: loci(:nyc))),
      create(:observation, taxon: taxa(:saxola), card: create(:card, observ_date: "2007-07-18")),
      create(:observation, taxon: taxa(:hirrus), card: create(:card, observ_date: "2009-08-09", locus: loci(:kyiv))),
    ]
  end

  test "show lifelist ordered by taxonomy" do
    get :basic, params: { sort: "by_taxonomy" }
    assert_response :success
    assert_select ".main" do
      assert_select "h3"
      assert_select "a[href='#{lifelist_path}']"
      assert_select "a[href='#{url_for(sort: :by_taxonomy, only_path: true)}']", false
    end
  end

  test "lifelist fails on invalid sort option" do
    assert_raise ActionController::RoutingError do
      get :basic, params: { sort: "by_moon_phase" }
    end
  end

  test "show default lifelist" do
    get :basic
    assert_response :success
    assert_select ".main" do
      #      assert_select 'h5' # should show "First time seen in..."
      assert_select "a[href='#{lifelist_path}']", false
      assert_select "a[href='#{url_for(sort: :by_taxonomy, only_path: true)}']"
    end
  end

  test "show year list by date" do
    get :basic, params: { year: 2009 }
    assert_response :success
    lifers = assigns(:lifelist)
    assert_equal [2009], lifers.to_a.map { |s| s.card.observ_date.year }.uniq
    assert_select ".main" do
      assert_select "h5", false # should not show "First time seen in..."
      assert_select "a[href='#{list_path(year: 2009)}']", false
      assert_select "a[href='#{url_for(sort: :by_taxonomy, year: 2009, only_path: true)}']"
    end
  end

  test "show year list by taxonomy" do
    get :basic, params: { sort: "by_taxonomy", year: 2009 }
    assert_response :success
    lifers = assigns(:lifelist)
    assert_equal [2009], lifers.to_a.map { |s| s.card.observ_date.year }.uniq
    assert_select ".main" do
      assert_select "h3" # should show order/family headings
      assert_select "a[href='#{list_path(year: 2009)}']"
      assert_select "a[href='#{url_for(sort: :by_taxonomy, year: 2009, only_path: true)}']", false
    end
  end

  test "show lifelist filtered by super location" do
    get :basic, params: { locus: "ukraine" }
    lifers = assigns(:lifelist)
    assert_equal 2, lifers.size
  end

  test "not allowed locus fails" do
    assert_raise(ActiveRecord::RecordNotFound) { get :basic, params: { locus: "sumy_obl" } }
    # assert_response :not_found
  end

  test "hardcoded country with no locus row renders an empty placeholder page" do
    # Canada is a hardcoded country (has a lifelist title) but has no Locus fixture.
    get :basic, params: { locus: "canada", locale: "en" }
    assert_response :not_found
    assert_kind_of PlaceholderCountry, assigns(:lifelist).locus
    assert_empty assigns(:lifelist).to_a
    assert_select "h1", text: "Canada List"
    assert_select "li", I18n.t("lifelist.basic.no_species")
  end

  test "hardcoded country does not fall back to the unfiltered global list" do
    # A missing locus row must yield an empty list, not every species.
    get :basic, params: { locus: "poland" }
    assert_empty assigns(:lifelist).to_a
  end

  test "lifelist links filter out invalid parameters" do
    get :basic, params: { sort: "by_taxonomy", year: 2009, zzz: "ooo" }
    assert_response :success
    assert_select ".main" do
      assert_select "a[href='#{list_path(year: 2009)}']"
      assert_select "a[href='#{url_for(sort: :by_taxonomy, year: 2009, only_path: true)}']", false
      assert_select "a[href='#{url_for(sort: :by_taxonomy, year: 2010, only_path: true)}']"
    end
  end

  test "empty lifelist shows no list" do
    get :basic, params: { year: 1899 }
    assert_response :not_found
    assert_select ".main" do
      assert_select "ol", false
      assert_select "li", I18n.t("lifelist.basic.no_species"), "No proper message found (saying no species in the list)"
    end
  end
end
