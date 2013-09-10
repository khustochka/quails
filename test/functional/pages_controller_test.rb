require 'test_helper'

class PagesControllerTest  < ActionController::TestCase

  test "get `links` public page" do
    get :show_public, id: 'links'
    assert_response :success
  end

  #test "get public page" do
  #  create(:page, slug: 'links')
  #  get :show, id: 'links'
  #  assert_response :success
  #end

  test "get private page by admin" do
    login_as_admin
    create(:page, slug: 'some', public: false)
    get :show, id: 'some'
    assert_response :success
  end

  #test "get private page by user" do
  #  create(:page, slug: 'links', public: false)
  #  assert_raise(ActiveRecord::RecordNotFound) { get :show, id: 'links' }
  #end

end
