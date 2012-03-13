require 'test_helper'

class MapsControllerTest < ActionController::TestCase

  test "admin should see Map" do
    login_as_admin
    get :show
    assert_response :success
  end

  test "admin should see edit map" do
    login_as_admin
    get :edit
    assert_response :success
  end

end