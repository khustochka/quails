require 'test_helper'

class ResearchControllerTest < ActionController::TestCase
  test "admin should see Research/index" do
    login_as_admin
    get :index
    assert_template 'index'
  end

  test "user should not see Research/index" do
    get :index
    assert_response 401
  end
end
