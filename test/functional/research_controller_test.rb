require 'test_helper'

class ResearchControllerTest < ActionController::TestCase
  test "render index template for admin" do
    login_as_admin
    get :index
    assert_template 'index'
  end

  test "not render index template for user" do
    get :index
    assert_response 401
  end
end
