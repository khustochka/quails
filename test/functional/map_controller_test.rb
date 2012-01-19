require 'test_helper'

class MapControllerTest < ActionController::TestCase

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

  test "should return spots" do
    login_as_admin
    get :spots, format: :json
    assert_response :success
    assert_equal Mime::JSON, response.content_type
  end

end