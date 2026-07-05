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

  test "shows My Statistics page" do
    get :stats
    assert_response :success
    # 2009: bomgar in the USA, jyntor in Ukraine
    assert_select "td.count_sp a[href=?]", list_path(year: 2009), text: "2"
    assert_select "li.ukraine .count a[href=?]", list_path(year: 2009, locus: "ukraine"), text: "1"
    assert_select "li.usa .count a[href=?]", list_path(year: 2009, locus: "usa"), text: "1"
    assert_select "tr.total td.count_sp a[href=?]", lifelist_path, text: "5"
    assert_select "tr.total li.usa .count a[href=?]", list_path(locus: "usa"), text: "3"
    assert_select "tr.total li.ukraine .count a[href=?]", list_path(locus: "ukraine"), text: "2"
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
