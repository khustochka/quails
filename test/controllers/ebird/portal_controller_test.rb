# frozen_string_literal: true

require "test_helper"

class EBird::PortalControllerTest < ActionController::TestCase
  test "should get index" do
    login_as_admin
    get :index
    assert_response :success
  end
end
