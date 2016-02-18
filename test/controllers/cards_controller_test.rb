require 'test_helper'

class CardsControllerTest < ActionController::TestCase
  setup do
    create(:observation)
    @card = create(:card)
    3.times { create(:observation, card: @card) }
    login_as_admin
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cards)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "new card should accept locus, date, and post" do
    p = create(:post)
    get :new, card: {locus_id: loci(:brovary).id, observ_date: '2013-04-26', post_id: p.id}
    assert_response :success
    card = assigns(:card)
    assert_equal loci(:brovary), card.locus
    assert_equal '2013-04-26', card.observ_date.iso8601
    assert_equal p, card.post
  end

  test "new card page should not explode if one of fast loci does not exist" do
    CardsHelper::FAST_LOCI << "some_loc"
    get :new
    assert_response :success
  end

  test "should create card" do
    assert_difference('Card.count') do
      post :create, card: attributes_for(:card)
    end

    assert_redirected_to edit_card_path(assigns(:card))
  end

  test "create card with observations" do
    observ_attrs = [{species_id: 2}, {species_id: 4}, {species_id: 6}]
    assert_difference('Observation.count', 3) do
      post :create, card: attributes_for(:card).merge(observations_attributes: observ_attrs)
    end

    assert_redirected_to edit_card_path(assigns(:card))
  end

  test "should show card" do
    get :show, id: @card
    assert_response :success
  end

  test "should show card with images" do
    create(:image, observations: [@card.observations.first])
    get :show, id: @card
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @card
    assert_response :success
  end

  test "should update card" do
    put :update, id: @card, card: attributes_for(:card)
    assert_redirected_to edit_card_path(assigns(:card))
  end

  test "move observations to existing card" do
    card2 = create(:card)
    obss = [1, 2, 3].map {|_| create(:observation, card: card2)}

    post :attach, id: @card, obs: [obss[0], obss[1]]

    @card.reload
    card2.reload

    assert_equal 5, @card.observations.size
    assert_equal 1, card2.observations.size

  end

  test "should not destroy card which is not empty" do
    assert_difference('Card.count', 0) do
      assert_raise(ActiveRecord::DeleteRestrictionError) { delete :destroy, id: @card }
    end
  end

  test "should destroy empty card" do
    @card.observations.each {|o| o.destroy }

    assert_difference('Card.count', -1) do
      delete :destroy, id: @card
    end

    assert_redirected_to cards_path
  end
end
