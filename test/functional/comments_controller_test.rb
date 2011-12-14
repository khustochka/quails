require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  setup do
    @comment = FactoryGirl.create(:comment)
  end

  test "should get index" do
    login_as_admin
    get :index
    assert_response :success
    assert_not_nil assigns(:comments)
  end

  test "should create comment" do
    assert_difference('Comment.count') do
      post :create, :comment => @comment.attributes
    end

    assert_redirected_to public_post_path(assigns(:comment).post)
    assert assigns(:comment).approved
  end

  test "should show comment" do
    login_as_admin
    get :show, :id => @comment.to_param
    assert_response :success
  end

  test "should get edit" do
    login_as_admin
    get :edit, :id => @comment.to_param
    assert_response :success
  end

  test "should update comment" do
    login_as_admin
    put :update, :id => @comment.to_param, :comment => @comment.attributes
    assert_redirected_to comment_path(assigns(:comment))
  end

  test "should destroy comment" do
    login_as_admin
    assert_difference('Comment.count', -1) do
      delete :destroy, :id => @comment.to_param
    end

    assert_redirected_to comments_path
  end
end
