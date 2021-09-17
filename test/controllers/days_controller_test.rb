# frozen_string_literal: true

require "test_helper"

class DaysControllerTest < ActionController::TestCase

  test "should get index" do
    create(:card)
    login_as_admin
    get :index
    assert_response :success
  end

  test "should get show" do
    card = create(:card)
    login_as_admin
    get :show, params: {id: card.observ_date.iso8601}
    assert_response :success
  end

end
