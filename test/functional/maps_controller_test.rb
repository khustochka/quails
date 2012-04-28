require 'test_helper'

class MapsControllerTest < ActionController::TestCase

  test "admin sees Map" do
    login_as_admin
    get :show
    assert_response :success
  end

  test "admin sees edit map" do
    login_as_admin
    get :edit
    assert_response :success
  end

end
