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

  test 'show hidden posts to admin when he is logged in' do
    blogpost1 = create(:post, face_date: '2007-12-06 13:14:15', status: 'PRIV')
    blogpost2 = create(:post, face_date: '2008-11-06 13:14:15')
    login_as_admin
    get :front_page
    assigns(:posts).select {|p| p.status == 'PRIV'}.should_not be_nil
    #assert_select "h2 a[href=#{public_post_path(blogpost1)}]"
    #assert_select "h2 a[href=#{public_post_path(blogpost2)}]"

    @controller = PostsController.new

    get :show, blogpost1.to_url_params
    assert_response :success

    get :show, blogpost2.to_url_params
    assert_response :success
  end

  test 'do not show hidden posts to user' do
    blogpost1 = create(:post, face_date: '2007-12-06 13:14:15', status: 'PRIV')
    blogpost2 = create(:post, face_date: '2008-11-06 13:14:15')
    get :front_page
    assigns(:posts).select {|p| p.status == 'PRIV'}.should be_empty

    @controller = PostsController.new

    assert_raises ActiveRecord::RecordNotFound do
      get :show, blogpost1.to_url_params
    end
#    TODO: assert_response :not_found

    get :show, blogpost2.to_url_params
    assert_response :success
  end

end