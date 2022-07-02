# frozen_string_literal: true

require "test_helper"

class SearchCardsControllerTest < ActionController::TestCase
  tests CardsController

  test "get index (no search)" do
    create(:observation, taxon: taxa(:pasdom), card: create(:card, observ_date: "2010-06-20", locus: loci(:nyc)))
    create(:observation, taxon: taxa(:jyntor), card: create(:card, observ_date: "2010-06-18"))
    create(:observation, taxon: taxa(:hirrus), card: create(:card, observ_date: "2009-06-18"))
    create(:observation, taxon: taxa(:saxola), card: create(:card, observ_date: "2007-07-18", locus: loci(:brovary)))
    create(:observation, taxon: taxa(:bomgar), card: create(:card, observ_date: "2009-08-09", locus: loci(:kyiv)))
    login_as_admin
    get :index
    assert_response :success
    assert assigns(:cards).present?, "Expected to assign cards"
  end

  test "get index (search)" do
    create(:observation, taxon: taxa(:pasdom), card: create(:card, observ_date: "2010-06-20", locus: loci(:nyc)))
    create(:observation, taxon: taxa(:hirrus), card: create(:card, observ_date: "2010-06-18"))
    create(:observation, taxon: taxa(:saxola), card: create(:card, observ_date: "2009-06-18"))
    create(:observation, taxon: taxa(:jyntor), card: create(:card, observ_date: "2007-07-18", locus: loci(:brovary)))
    create(:observation, taxon: taxa(:gargla), card: create(:card, observ_date: "2009-08-09", locus: loci(:kyiv)))
    login_as_admin
    get :index, params: {q: {locus_id: loci(:brovary).id}}
    assert_response :success
    assert_equal 3, assigns(:cards).size
  end

  test "Spuhs properly rendered on index page" do
    create(:observation, taxon: taxa(:aves_sp), card: create(:card, observ_date: "2010-06-18"))
    create(:observation, taxon: taxa(:aves_sp), card: create(:card, observ_date: "2009-06-19"))
    login_as_admin
    aves_sp_id = taxa(:aves_sp).id
    get :index, params: {q: {taxon_id: aves_sp_id}}
    assert_response :success
    cards = assigns(:cards)
    assert_not_nil cards
    assert cards.find { |c| (c.observations.find { |o| o.taxon_id == aves_sp_id }).present? }.present?,
      "Expected to include Bird sp."
    assert_select "li b", "bird sp."
  end
end
