# frozen_string_literal: true

require "test_helper"

class EBird::AlertsControllerTest < ActionController::TestCase
  test "should get index without configured alerts" do
    login_as_admin
    get :index
    assert_response :success
  end
end
