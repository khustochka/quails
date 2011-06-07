require 'test_helper'

class PostsControllerTest < ActionController::TestCase

  should "get new" do
    login_as_admin
    get :new
    assert_response :success
  end

  should "create post" do
    blogpost = Factory.build(:post)
    assert_difference('Post.count') do
      login_as_admin
      post :create, :post => blogpost.attributes
    end
    assert_redirected_to public_post_path(assigns(:post))
  end

  should "show post" do
    blogpost = Factory.create(:post)
    get :show, blogpost.to_url_params
    assert_response :success
  end

  should "get edit" do
    blogpost = Factory.create(:post)
    login_as_admin
    get :edit, :id => blogpost.to_param
    assert_response :success
    assert_select "a[href=#{public_post_path(blogpost)}]", true
  end

  should "update post" do
    blogpost = Factory.create(:post)
    blogpost.title = 'Changed title'
    login_as_admin
    put :update, :id => blogpost.to_param, :post => blogpost.attributes
    assert_redirected_to public_post_path(assigns(:post))
  end

  should "not update post with invalid attribute" do
    blogpost = Factory.create(:post)
    blogpost.title = ''
    login_as_admin
    put :update, :id => blogpost.to_param, :post => blogpost.attributes
    assert_template :edit
  end

  should "not update post with invalid code" do
    blogpost = Factory.create(:post)
    blogpost2 = blogpost.dup
    blogpost2.code = ''
    login_as_admin
    put :update, :id => blogpost.code, :post => blogpost2.attributes
    assert_template :edit
    assert_select "form[action=#{post_path(blogpost)}]"
  end

  should "destroy post" do
    blogpost = Factory.create(:post)
    assert_difference('Post.count', -1) do
      login_as_admin
      delete :destroy, :id => blogpost.to_param
    end
    assert_redirected_to root_path
  end

  should "redirect to correct URL if year and month are incorrect" do
    blogpost = Factory.create(:post, :face_date => '2007-12-06 13:14:15')
    get :show, {:id => blogpost.code, :year => 2010, :month => '01'}
#    assert_response 301
    assert_redirected_to public_post_path(blogpost)
  end

  # HTTP auth tests

  should 'protect new with HTTP authentication' do
    get :new
    assert_response 401
  end

  should 'protect edit with HTTP authentication' do
    blogpost = Factory.create(:post)
    get :edit, :id => blogpost.to_param
    assert_response 401
  end

  should 'protect create with HTTP authentication' do
    observation = Factory.build(:observation)
    post :create, :observation => observation.attributes
    assert_response 401
  end

  should 'protect update with HTTP authentication' do
    blogpost = Factory.create(:post)
    blogpost.title = 'Changed title'
    put :update, :id => blogpost.to_param, :post => blogpost.attributes
    assert_response 401
  end

  should 'protect destroy with HTTP authentication' do
    blogpost = Factory.create(:post)
    delete :destroy, :id => blogpost.to_param
    assert_response 401
  end
end
