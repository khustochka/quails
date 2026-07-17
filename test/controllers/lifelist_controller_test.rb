# frozen_string_literal: true

require "test_helper"

class LifelistControllerTest < ActionController::TestCase
  setup do
    @obs = [
      create(:observation, taxon: taxa(:pasdom), card: create(:card, observ_date: "2010-06-20", locus: loci(:nyc))),
      create(:observation, taxon: taxa(:hirrus), card: create(:card, observ_date: "2010-06-18", locus: loci(:nyc))),
      create(:observation, taxon: taxa(:bomgar), card: create(:card, observ_date: "2009-06-18", locus: loci(:nyc))),
      create(:observation, taxon: taxa(:saxola), card: create(:card, observ_date: "2007-07-18")),
      create(:observation, taxon: taxa(:jyntor), card: create(:card, observ_date: "2009-08-09", locus: loci(:kyiv))),
    ]
  end

  test "get index" do
    %w(united_kingdom canada).each do |sl|
      create(:locus, slug: sl, loc_type: "country")
    end
    get :index
    assert_select ".sp_link_long", "House Sparrow Passer domesticus"
    assert_response :success
  end

  test "index renders with no observations" do
    Observation.destroy_all
    %w(united_kingdom canada).each do |sl|
      create(:locus, slug: sl, loc_type: "country")
    end
    get :index
    assert_response :success
  end

  test "index shows an empty list for a hardcoded country with no locus row" do
    # Canada has observations here but no Locus row; the placeholder must keep
    # its list empty instead of falling back to the unfiltered global list.
    create(:observation, taxon: taxa(:pasdom),
      card: create(:card, observ_date: "2010-06-20", locus: loci(:nyc)))
    create(:locus, slug: "united_kingdom", loc_type: "country")
    get :index
    assert_response :success
    assert_kind_of PlaceholderCountry, assigns(:list_canada).locus
    assert_equal 0, assigns(:list_canada).total_count
  end

  test "index hides hidden observations from visitors" do
    %w(united_kingdom canada).each do |sl|
      create(:locus, slug: sl, loc_type: "country")
    end
    create(:observation, taxon: taxa(:motfel), hidden: true,
      card: create(:card, observ_date: "2011-06-20", locus: loci(:nyc)))
    get :index
    assert_select ".sp_link_long", text: /Black-headed Wagtail/, count: 0
  end

  test "index shows hidden observations to admin" do
    %w(united_kingdom canada).each do |sl|
      create(:locus, slug: sl, loc_type: "country")
    end
    create(:observation, taxon: taxa(:motfel), hidden: true,
      card: create(:card, observ_date: "2011-06-20", locus: loci(:nyc)))
    login_as_admin
    get :index
    assert_select ".sp_link_long", text: /Black-headed Wagtail/, count: 1
  end

  test "shows My Statistics page" do
    get :stats
    assert_response :success
    # 2009: bomgar in the USA, jyntor in Ukraine
    assert_select "td.species a[href=?]", list_path(year: 2009), text: "2"
    assert_select "td.lifers a[href=?]", advanced_list_path(anchor: "first_seen_2009"), text: "+2"
    assert_select "li.ukraine a[href=?] .count", list_path(year: 2009, locus: "ukraine"), text: "1"
    assert_select "li.usa a[href=?] .count", list_path(year: 2009, locus: "usa"), text: "1"
    assert_select "tfoot tr.total td.species a[href=?]", lifelist_path, text: "5"
    assert_select "tfoot tr.total li.usa a[href=?] .count", list_path(locus: "usa"), text: "3"
    assert_select "tfoot tr.total li.ukraine a[href=?] .count", list_path(locus: "ukraine"), text: "2"
    # 2009 and 2010 tie for most species (2) and most lifers (2); 2007 is highlighted in neither
    assert_select "td.species.year-max a[href=?]", list_path(year: 2009), text: "2"
    assert_select "td.species.year-max", 2
    assert_select "td.lifers.year-max a[href=?]", advanced_list_path(anchor: "first_seen_2010"), text: "+2"
    assert_select "td.lifers.year-max", 2
  end

  test "stats renders with no observations" do
    Observation.destroy_all
    get :stats
    assert_response :success
    # No record-setting days when there are no observations.
    assert_select ".record-days", count: 0
  end

  test "stats renders on an empty database with no countries" do
    # Empty DB: no observations and no countries. country_case_sql must not
    # build an empty CASE, which is a PG syntax error.
    Observation.destroy_all
    Card.delete_all
    Locus.delete_all
    assert_empty Country.all
    get :stats
    assert_response :success
  end

  test "stats orders countries by first visit" do
    get :stats
    # 2009 row (second year): the USA (June) was visited before Ukraine (August)
    assert_select "tbody tr:nth-child(2) td.countries li:first-child.usa"
    assert_select "tbody tr:nth-child(2) td.countries li:last-child.ukraine"
    # Total row: Ukraine (2007) comes before the USA (2009)
    assert_select "tfoot td.countries li:first-child.ukraine"
  end

  test "stats shows record days derived from observations" do
    # A second (new) species on 2010-06-18 makes it both the most-species
    # and the most-lifers day.
    create(:observation, taxon: taxa(:motfel),
      card: create(:card, observ_date: "2010-06-18", locus: loci(:nyc)))
    get :stats
    assert_select ".record-days li.record-species" do
      assert_select ".record-count", text: "2"
      assert_select "time[datetime=?]", "2010-06-18"
      assert_select ".record-place", text: "Нью-Йорк — шт. Нью-Йорк — США"
    end
    assert_select ".record-days li.record-lifers" do
      assert_select ".record-count", text: "+2"
      assert_select "time[datetime=?]", "2010-06-18"
    end
  end

  test "stats excludes hidden observations for visitors" do
    create(:observation, taxon: taxa(:motfel), hidden: true,
      card: create(:card, observ_date: "2009-08-09", locus: loci(:nyc)))
    get :stats
    assert_select "tfoot tr.total td.species a[href=?]", lifelist_path, text: "5"
    assert_select "td.species a[href=?]", list_path(year: 2009), text: "2"
    assert_select "tfoot tr.total li.usa a[href=?] .count", list_path(locus: "usa"), text: "3"
  end

  test "stats includes hidden observations for admin" do
    create(:observation, taxon: taxa(:motfel), hidden: true,
      card: create(:card, observ_date: "2009-08-09", locus: loci(:nyc)))
    login_as_admin
    get :stats
    assert_select "tfoot tr.total td.species a[href=?]", lifelist_path, text: "6"
    assert_select "td.species a[href=?]", list_path(year: 2009), text: "3"
    assert_select "tfoot tr.total li.usa a[href=?] .count", list_path(locus: "usa"), text: "4"
  end

  test "eBird Lifelist page" do
    get :ebird
    assert_response :success
  end

  test "charts are rendered even with no observations" do
    login_as_admin
    get :chart
    assert_response :success
    # Lifers section is present by default in both charts
    assert_select ".lifelist-chart-lifers", 2
  end
end
