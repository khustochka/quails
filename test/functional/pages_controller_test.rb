require 'test_helper'

class PagesControllerTest  < ActionController::TestCase

  test "get public page" do
    create(:page, slug: 'links')
    get :show, id: 'links'
    assert_response :success
  end

  test "get private page by admin" do
    login_as_admin
    create(:page, slug: 'links', public: false)
    get :show, id: 'links'
    assert_response :success
  end

  test "get private page by user" do
    create(:page, slug: 'links', public: false)
    get :show, id: 'links'
    assert_response :not_found
  end

end
