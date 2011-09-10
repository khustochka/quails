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

  test "admin should see Research/lifelist" do
    login_as_admin
    get :lifelist
    assert_response :success
  end

  test "admin should see Research/more_than_year" do
    login_as_admin
    get :more_than_year
    assert_response :success
  end
end
