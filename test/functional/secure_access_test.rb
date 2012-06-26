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
    assigns(:posts).should include(blogpost1, blogpost2)

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
    assigns(:posts).should include(blogpost2)
    assigns(:posts).should_not include(blogpost1)

    @controller = PostsController.new

    expect { get :show, blogpost1.to_url_params }.to raise_error(ActiveRecord::RecordNotFound)

    get :show, blogpost2.to_url_params
    assert_response :success
  end

end
