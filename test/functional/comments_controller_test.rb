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

  test "get index sorted by post" do
    login_as_admin
    get :index, sort: 'by_post'
    assert_response :success
    assert_not_nil assigns(:comments)
  end

  test "create comment" do
    assert_difference('Comment.count') do
      post :create, comment: attributes_for(:comment, post_id: @comment.post_id)
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

  test "user cannot create comment to hidden post" do
    assert_raise(ActiveRecord::RecordNotFound) do
      assert_difference('Comment.count', 0) do
        post :create, comment: attributes_for(:comment, post_id: create(:post, status: 'PRIV').id)
      end
    end
  end

  test "admin can create comment to hidden post" do
    login_as_admin
    assert_difference('Comment.count', 1) do
      post :create, comment: attributes_for(:comment, post_id: create(:post, status: 'PRIV').id)
    end
  end

  test "user does not see reply page to hidden post" do
    comment = create(:comment, post: create(:post, status: 'PRIV'))
    assert_raise(ActiveRecord::RecordNotFound) { get :reply, id: comment.to_param }
  end
end
