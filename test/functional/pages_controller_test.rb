require 'test_helper'

class PagesControllerTest  < ActionController::TestCase

  test "get links page" do
    get :show, id: 'links'
    assert_response :success
  end

  test "get about page" do
    get :show, id: 'about'
    assert_response :success
  end

end
