require 'test_helper'

class EbirdControllerTest < ActionController::TestCase

  test "should get list of ebird files" do
    obs = FactoryGirl.create(:observation)
    FactoryGirl.create(:ebird_file, cards: [obs.card])
    login_as_admin
    get :index
    assert_response :success
  end

  test 'new ebird action' do
    login_as_admin
    get :new
    assert assigns(:file)
    assert_response :success
  end

  test "create ebird file object with valid params" do
    card1 = FactoryGirl.create(:observation).card
    card2 = FactoryGirl.create(:observation).card
    login_as_admin

    assert_difference("Ebird::File.count", 1) do
      get :create, {ebird_file: {name: "fileAAA"}, card_id: [card1.id, card2.id]}
    end

    assert_redirected_to controller: :ebird, action: :show, id: Ebird::File.last
  end

  test "do not create ebird file object without name" do
    card1 = FactoryGirl.create(:card)
    card2 = FactoryGirl.create(:card)
    login_as_admin
    assert_difference("Ebird::File.count", 0) do
      get :create, {ebird_file: {name: ""}, card_id: [card1.id, card2.id]}
    end
  end

  test "do not create ebird file object without cards" do
    login_as_admin
    assert_difference("Ebird::File.count", 0) do
      get :create, {ebird_file: {name: "fileBBB"}}
    end

    assert_template 'new'
    assert flash[:alert].present?

  end

end
