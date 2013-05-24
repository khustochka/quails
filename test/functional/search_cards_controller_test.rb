require 'test_helper'

class SearchCardsControllerTest < ActionController::TestCase

  tests CardsController

  test "get index (no search)" do
    create(:observation, species: seed(:pasdom), card: create(:card, observ_date: "2010-06-20", locus: seed(:new_york)))
    create(:observation, species: seed(:melgal), card: create(:card, observ_date: "2010-06-18"))
    create(:observation, species: seed(:anapla), card: create(:card, observ_date: "2009-06-18"))
    create(:observation, species: seed(:anacly), card: create(:card, observ_date: "2007-07-18", locus: seed(:brovary)))
    create(:observation, species: seed(:embcit), card: create(:card, observ_date: "2009-08-09", locus: seed(:kherson)))
    login_as_admin
    get :index
    assert_response :success
    assert_present assigns(:cards)
  end

  test "get index (search)" do
    create(:observation, species: seed(:pasdom), card: create(:card, observ_date: "2010-06-20", locus: seed(:new_york)))
    create(:observation, species: seed(:melgal), card: create(:card, observ_date: "2010-06-18"))
    create(:observation, species: seed(:anapla), card: create(:card, observ_date: "2009-06-18"))
    create(:observation, species: seed(:anacly), card: create(:card, observ_date: "2007-07-18", locus: seed(:brovary)))
    create(:observation, species: seed(:embcit), card: create(:card, observ_date: "2009-08-09", locus: seed(:kherson)))
    login_as_admin
    get :index, q: {locus_id: seed(:brovary).id}
    assert_response :success
    assert_equal 3, assigns(:cards).size
  end

  test "Avis incognita properly rendered on index page" do
    create(:observation, species_id: 0, card: create(:card, observ_date: "2010-06-18"))
    create(:observation, species_id: 0, card: create(:card, observ_date: "2009-06-19"))
    login_as_admin
    get :index, q: {species_id: 0}
    assert_response :success
    cards = assigns(:cards)
    assert_not_nil cards
    assert_present cards.find {|c| (c.observations.find {|o| o.species_id == 0}).present? }
    #assert_select 'td', '- Avis incognita'
  end

end
