require 'test_helper'

class SearchCardsControllerTest < ActionController::TestCase

  tests CardsController

  test "get index (no search)" do
    create(:observation, species: seed(:pasdom), card: create(:card, observ_date: "2010-06-20", locus: loci(:nyc)))
    create(:observation, species: seed(:melgal), card: create(:card, observ_date: "2010-06-18"))
    create(:observation, species: seed(:anapla), card: create(:card, observ_date: "2009-06-18"))
    create(:observation, species: seed(:anacly), card: create(:card, observ_date: "2007-07-18", locus: loci(:brovary)))
    create(:observation, species: seed(:embcit), card: create(:card, observ_date: "2009-08-09", locus: loci(:kiev)))
    login_as_admin
    get :index
    assert_response :success
    assert assigns(:cards).present?, "Expected to assign cards"
  end

  test "get index (search)" do
    create(:observation, species: seed(:pasdom), card: create(:card, observ_date: "2010-06-20", locus: loci(:nyc)))
    create(:observation, species: seed(:melgal), card: create(:card, observ_date: "2010-06-18"))
    create(:observation, species: seed(:anapla), card: create(:card, observ_date: "2009-06-18"))
    create(:observation, species: seed(:anacly), card: create(:card, observ_date: "2007-07-18", locus: loci(:brovary)))
    create(:observation, species: seed(:embcit), card: create(:card, observ_date: "2009-08-09", locus: loci(:kiev)))
    login_as_admin
    get :index, q: {locus_id: loci(:brovary).id}
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
    assert cards.find { |c| (c.observations.find { |o| o.species_id == 0 }).present? }.present?,
           "Expected to include Avis incognita"
    assert_select 'li b', '- Avis incognita'
  end

end
