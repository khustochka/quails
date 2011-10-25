require 'test_helper'

class ResearchControllerTest < ActionController::TestCase
  test "admin should see Research/index" do
    login_as_admin
    get :index
    assert_template 'index'
  end

  test "user should not see Research/index" do
    assert_raises(ActionController::RoutingError) { get :index }
    #assert_response 404
  end

  test "admin should see Research/lifelist" do
    login_as_admin
    assert_nothing_raised do
      get :lifelist
    end
    assert_response :success
  end

  test "admin should see Research/more_than_year" do
    login_as_admin
    assert_nothing_raised do
      get :more_than_year
    end
    assert_response :success
  end

  test "admin should see Research/unpictured" do
    login_as_admin
    assert_nothing_raised do
      get :unpictured
    end
    assert_response :success
  end
end
