require 'test_helper'

class DiscoverControllerTest < ActionController::TestCase
    
  context "index action" do
    should "render index template for admin" do
      login_as_admin
      get :index
      assert_template 'index'
    end

    should "not render index template for user" do
      get :index
    assert_response 401
    end
  end
                
end
