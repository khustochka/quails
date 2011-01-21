require 'test_helper'

class SecureAccessTest < ActionController::TestCase

  tests PostsController

  should 'show administrative panel to admin after he logged in' do
    authenticate_with_http_basic
    get :new # log in should happen here
    get :index
    assert_select '.admin_panel', true
  end

  should 'not show administrative panel to user' do
    get :index
    assert_select '.admin_panel', false
  end

end