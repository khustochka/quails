require "test_helper"

class LoginControllerTest < ActionController::TestCase

  test 'Admin can login' do
    login_as_admin
    get :login
    assert_redirected_to root_url
  end

  test 'Ordinary user cannot login' do
    get :login
    assert_response 401
  end

end