# frozen_string_literal: true

require "test_helper"

class DaysControllerTest < ActionController::TestCase


  test "should get index" do
    login_as_admin
    get :index
    assert_response :success
  end

  test "should get show" do
    login_as_admin
    get :show, params: {id: "2017-03-06"}
    assert_response :success
  end


end
