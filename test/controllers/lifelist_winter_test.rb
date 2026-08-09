# frozen_string_literal: true

require "test_helper"

class LifelistWinterTest < ActionController::TestCase
  tests LifelistController

  setup do
    # The 2009–10 season spans two calendar years; the July record is outside
    # any winter and must never appear.
    @dec = create(:observation, taxon: taxa(:pasdom),
      card: create(:card, observ_date: "2009-12-20", locus: loci(:nyc)))
    @jan = create(:observation, taxon: taxa(:jyntor),
      card: create(:card, observ_date: "2010-01-15", locus: loci(:nyc)))
    @other_winter = create(:observation, taxon: taxa(:bomgar),
      card: create(:card, observ_date: "2007-02-10", locus: loci(:nyc)))
    @summer = create(:observation, taxon: taxa(:saxola),
      card: create(:card, observ_date: "2007-07-18"))
  end

  test "show winter list" do
    get :winter
    assert_response :success
    assert_equal 3, assigns(:lifelist).size
  end

  test "winter list excludes observations outside December-February" do
    assert_not_includes assigns_species(:winter), @summer.species_id
  end

  test "a winter season runs from December into the next February" do
    get :winter, params: { year: 2009 }
    assert_response :success
    assert_equal [@dec.species_id, @jan.species_id].sort, assigns(:lifelist).map { |l| l.species.id }.sort
  end

  test "season filter offers the December year of each season" do
    get :winter
    assert_response :success
    # February 2007 belongs to the season that started in December 2006.
    assert_equal [nil, 2006, 2009], assigns(:lifelist).years
  end

  test "season filter spans both years of the season" do
    get :winter, params: { locale: "en" }
    assert_response :success
    assert_select ".lifelist-filters" do
      assert_select "a", text: "2009–10"
      assert_select "a", text: "2006–07"
    end
  end

  test "season heading spans both years of the season" do
    get :winter, params: { locale: "en" }
    assert_response :success
    assert_select "h2", text: "First encounter in winter 2009–10:"
  end

  test "page title names the season" do
    get :winter, params: { year: 2009, locale: "en" }
    assert_response :success
    assert_select "h1", text: /Winter list 2009–10/
  end

  test "show winter list ordered by taxonomy" do
    get :winter, params: { sort: "taxonomy" }
    assert_response :success
    assert_select ".lifelist-page h3"
  end

  test "winter list fails on invalid sort option" do
    assert_raise ActionController::RoutingError do
      get :winter, params: { sort: "by_moon_phase" }
    end
  end

  # An out-of-range year would otherwise build a Date beyond PostgreSQL's range
  # and blow up in the season query.
  test "winter list fails on an out-of-range year" do
    assert_raise ActionController::RoutingError do
      get :winter, params: { year: "99999999" }
    end
  end

  test "winter list for a locus" do
    get :winter, params: { locus: "new_york_city" }
    assert_response :success
    assert_not_includes assigns(:lifelist).map { |l| l.species.id }, @summer.species_id
  end

  test "unknown locus is not found" do
    assert_raise ActiveRecord::RecordNotFound do
      get :winter, params: { locus: "nowhere" }
    end
  end

  test "empty winter list renders the page with 404" do
    Observation.delete_all
    get :winter
    assert_response :not_found
  end

  test "do not include hidden observations into public winter list" do
    create(:observation, taxon: taxa(:larheu),
      card: create(:card, observ_date: "2010-02-02"), hidden: true)
    get :winter
    assert_response :success
    assert_equal 3, assigns(:lifelist).size
  end

  private

  def assigns_species(action)
    get action
    assigns(:lifelist).map { |lifer| lifer.species.id }
  end
end
