require 'test_helper'

class SecureAccessTest < ActionController::TestCase

  tests BlogController

  test 'show administrative panel to admin when he is logged in' do
    login_as_admin
    get :front_page
    assert_select '.admin_menu', true
  end

  test 'do not show administrative panel to user' do
    get :front_page
    assert_select '.admin_panel', false
  end

end
