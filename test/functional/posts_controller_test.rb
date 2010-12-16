require 'test_helper'

class PostsControllerTest < ActionController::TestCase

  setup do
  end

  test "should get index" do
    blogpost = Factory.create(:post)
    get :index
    assert_response :success
    assert_select "h2 a[href=#{public_post_path(blogpost)}]"
  end

  test "should get posts list for a year" do
    blogpost1 = Factory.create(:post, :created_at => '2007-12-06 13:14:15', :code => 'post-one')
    blogpost2 = Factory.create(:post, :created_at => '2008-11-06 13:14:15', :code => 'post-two')
    get :year, :year => 2007
    assert_response :success
    assert_select "li a[href=#{public_post_path(blogpost1)}]", true
    assert_select "li a[href=#{public_post_path(blogpost2)}]", false
    assert_select "a[href='/2007/12']", '12'
  end

  test "should get posts list for a month" do
    blogpost1 = Factory.create(:post, :created_at => '2007-12-06 13:14:15', :code => 'post-one')
    blogpost2 = Factory.create(:post, :created_at => '2007-11-06 13:14:15', :code => 'post-two')
    get :month, :year => 2007, :month => 12
    assert_response :success
    assert_select "h2 a[href=#{public_post_path(blogpost1)}]", true
    assert_select "h2 a[href=#{public_post_path(blogpost2)}]", false
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create post" do
    blogpost = Factory.build(:post)
    assert_difference('Post.count') do
      post :create, :post => blogpost.attributes
    end

    assert_redirected_to public_post_path(assigns(:post))
  end

  test "should show post" do
    blogpost = Factory.create(:post)
    get :show, blogpost.to_url_params
    assert_response :success
#    assert_select "a[href=#{edit_post_path(blogpost)}]", true
  end

  test "should get edit" do
    blogpost = Factory.create(:post)
    get :edit, :id => blogpost.to_param
    assert_response :success
#    assert_select "a[href=#{public_post_path(blogpost)}]", true
  end

  test "should update post" do
    blogpost = Factory.create(:post)
    blogpost.title = 'Changed title'
    put :update, :id => blogpost.to_param, :post => blogpost.attributes
    assert_redirected_to public_post_path(assigns(:post))
  end

  test "should destroy post" do
    blogpost = Factory.create(:post)
    assert_difference('Post.count', -1) do
      delete :destroy, :id => blogpost.to_param
    end

    assert_redirected_to posts_path
  end

  should "redirect to correct URL if year and month are incorrect" do
    blogpost = Factory.create(:post, :created_at => '2007-12-06 13:14:15')
    get :show, {:id => blogpost.code, :year => 2010, :month => '01'}
    assert_redirected_to public_post_path(blogpost)
  end
end
