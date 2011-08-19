require 'test_helper'

class SecureAccessTest < ActionController::TestCase

  tests PostsController

  test 'show administrative panel to admin when he is logged in' do
    login_as_admin
    get :index
    assert_select '.admin_menu', true
  end

  test 'not show administrative panel to user' do
    get :index
    assert_select '.admin_panel', false
  end

  test 'show hidden posts to admin when he is logged in' do
    blogpost1 = Factory.create(:post, :face_date => '2007-12-06 13:14:15', :code => 'post-one', :status => 'PRIV')
    blogpost2 = Factory.create(:post, :face_date => '2008-11-06 13:14:15', :code => 'post-two')
    login_as_admin
    get :index
    assert_select "h2 a[href=#{public_post_path(blogpost1)}]"
    assert_select "h2 a[href=#{public_post_path(blogpost2)}]"

    get :show, blogpost1.to_url_params
    assert_response :success

    get :show, blogpost2.to_url_params
    assert_response :success
  end

  test 'not show hidden posts to user' do
    blogpost1 = Factory.create(:post, :face_date => '2007-12-06 13:14:15', :code => 'post-one', :status => 'PRIV')
    blogpost2 = Factory.create(:post, :face_date => '2008-11-06 13:14:15', :code => 'post-two')
    get :index
    assert_select "h2 a[href=#{public_post_path(blogpost1)}]", false
    assert_select "h2 a[href=#{public_post_path(blogpost2)}]"

    assert_raises ActiveRecord::RecordNotFound do
      get :show, blogpost1.to_url_params
    end
#    TODO: assert_response :not_found

    get :show, blogpost2.to_url_params
    assert_response :success
  end

end