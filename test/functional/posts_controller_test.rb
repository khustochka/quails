require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  setup do
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:posts)
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

    assert_redirected_to post_path(assigns(:post))
  end

  test "should show post" do
    blogpost = Factory.create(:post)
    get :show, :id => blogpost.to_param
    assert_response :success
  end

  test "should get edit" do
    blogpost = Factory.create(:post)
    get :edit, :id => blogpost.to_param
    assert_response :success
  end

  test "should update post" do
    blogpost = Factory.create(:post)
    blogpost.title = 'Changed title'
    put :update, :id => blogpost.to_param, :post => blogpost.attributes
    assert_redirected_to post_path(assigns(:post))
  end

  test "should destroy post" do
    blogpost = Factory.create(:post)
    assert_difference('Post.count', -1) do
      delete :destroy, :id => blogpost.to_param
    end

    assert_redirected_to posts_path
  end
end
