# frozen_string_literal: true

require "test_helper"

class Ebird::SubmissionsControllerTest < ActionController::TestCase
  test "should get list of ebird files" do
    obs = FactoryBot.create(:observation)
    FactoryBot.create(:ebird_file, cards: [obs.card])
    login_as_admin
    get :index
    assert_response :success
  end

  test "new ebird action" do
    login_as_admin
    get :new
    assert assigns(:file)
    assert_response :success
  end

  test "new ebird with search" do
    card1 = FactoryBot.create(:card, observ_date: "2016-01-01")
    card2 = FactoryBot.create(:card, observ_date: "2016-01-03")
    login_as_admin
    get :new, params: { q: { observ_date: "2016-01-01", end_date: "2016-01-03" } }
    assert_response :success
    file = assigns(:file)
    assert_equal "ukraine-20160101-20160103", file.name
  end

  test "create ebird file object with valid params" do
    card1 = FactoryBot.create(:observation).card
    card2 = FactoryBot.create(:observation).card
    login_as_admin

    assert_difference("Ebird::File.count", 1) do
      get :create, params: { ebird_file: { name: "fileAAA" }, card_id: [card1.id, card2.id] }
    end

    assert_redirected_to controller: :submissions, action: :show, id: Ebird::File.last
  end

  test "do not create ebird file object without name" do
    card1 = FactoryBot.create(:card)
    card2 = FactoryBot.create(:card)
    login_as_admin
    assert_difference("Ebird::File.count", 0) do
      get :create, params: { ebird_file: { name: "" }, card_id: [card1.id, card2.id] }
    end
  end

  test "do not create ebird file object without cards" do
    login_as_admin
    assert_difference("Ebird::File.count", 0) do
      get :create, params: { ebird_file: { name: "fileBBB" } }
    end

    assert_template "new"
    assert flash[:alert].present?
  end
end
