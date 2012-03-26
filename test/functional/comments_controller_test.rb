require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  setup do
    @comment = create(:comment)
  end

  test "get index" do
    login_as_admin
    get :index
    assert_response :success
    assert_not_nil assigns(:comments)
  end

  test "create comment" do
    assert_difference('Comment.count') do
      post :create, comment: @comment.attributes
    end

    comment = assigns(:comment)
    assert_redirected_to public_comment_path(comment)
    assert assigns(:comment).approved
  end

  test "show comment" do
    login_as_admin
    get :show, id: @comment.to_param
    assert_response :success
  end

  test "get reply comment page" do
    get :reply, id: @comment.to_param
    assert_response :success
  end

  test "get edit" do
    login_as_admin
    get :edit, id: @comment.to_param
    assert_response :success
  end

  test "update comment" do
    login_as_admin
    put :update, id: @comment.to_param, comment: @comment.attributes
    assert_redirected_to comment_path(assigns(:comment))
  end

  test "destroy comment" do
    login_as_admin
    assert_difference('Comment.count', -1) do
      delete :destroy, id: @comment.to_param
    end

    assert_redirected_to public_post_path(@comment.post, anchor: 'comments')
  end
end
