# frozen_string_literal: true

require "test_helper"

class CommentsControllerTest < ActionController::TestCase
  setup do
    @comment = create(:comment)
  end

  def valid_comment_params(args = {})
    attrs = attributes_for(:comment, {name: "", post_id: @comment.post.id}.merge(args))
    name = "Vasya"
    {CommentsHelper::REAL_NAME_FIELD => name, comment: attrs}
  end
  private :valid_comment_params

  test "get index" do
    login_as_admin
    get :index
    assert_response :success
    assert_not_nil assigns(:comments)
  end

  test "get index sorted by post" do
    login_as_admin
    get :index, params: {sort: "by_post"}
    assert_response :success
    assert_not_nil assigns(:comments)
  end

  test "create comment" do
    assert_difference("Comment.count") do
      post :create, params: valid_comment_params
    end

    comment = assigns(:comment)
    assert_redirected_to public_comment_path(comment)
    assert_predicate comment, :approved
    assert_equal "Vasya", comment.name
  end

  test "reject comment with negative captcha" do
    invalid_attrs = valid_comment_params(name: "Vasya")
    assert_difference("Comment.count", 0) do
      post :create, params: invalid_attrs
    end

    comment = assigns(:comment)
    assert_response 422
  end

  test "screen comment with stop word in the body" do
    post :create, params: valid_comment_params(body: "Hi friend. Buy #{Comment::STOP_WORDS.sample}. Thanks")

    comment = assigns(:comment)
    assert_redirected_to public_comment_path(comment)
    assert_not_predicate comment, :approved
  end

  test "show comment" do
    login_as_admin
    get :show, params: {id: @comment.to_param}
    assert_response :success
  end

  test "get reply comment page" do
    get :reply, params: {id: @comment.to_param}
    assert_response :success
  end

  test "get edit" do
    login_as_admin
    get :edit, params: {id: @comment.to_param}
    assert_response :success
  end

  test "update comment" do
    login_as_admin
    put :update, params: {id: @comment.to_param, comment: @comment.attributes}
    assert_redirected_to comment_path(assigns(:comment))
  end

  test "destroy comment" do
    login_as_admin
    assert_difference("Comment.count", -1) do
      delete :destroy, params: {id: @comment.to_param}
    end

    assert_redirected_to public_post_path(@comment.post, anchor: "comments")
  end

  test "user cannot create comment to hidden post" do
    assert_raise(ActiveRecord::RecordNotFound) do
      post :create, params: {comment: valid_comment_params(post_id: create(:post, status: "PRIV").id)}
    end
  end

  test "admin can create comment to hidden post" do
    login_as_admin
    assert_difference("Comment.count", 1) do
      post :create, params: valid_comment_params(post_id: create(:post, status: "PRIV").id)
    end
  end

  test "user does not see reply page to hidden post" do
    comment = create(:comment, post: create(:post, status: "PRIV"))
    assert_raise(ActiveRecord::RecordNotFound) { get :reply, params: {id: comment.to_param} }
  end

  test "user can create comment with his email" do
    user_commenter = Commenter.create!(is_admin: false, name: "Vasya", email: "user@example.org")
    email = user_commenter.email
    blogpost = create(:post)
    post :create, params: valid_comment_params(post_id: blogpost.id).merge(commenter: {email: email})
    comment = assigns(:comment)
    assert_equal user_commenter, comment.commenter
  end

  test "admin can create comment with their email" do
    login_as_admin
    admin_commenter = Commenter.create!(is_admin: true, name: "Admin", email: "admin@example.org")
    email = admin_commenter.email
    blogpost = create(:post)
    post :create, params: valid_comment_params(post_id: blogpost.id).merge(commenter: {email: email})
    comment = assigns(:comment)
    assert_equal admin_commenter, comment.commenter
  end

  test "user cannot create comment posing as admin (using admin email)" do
    admin_commenter = Commenter.create!(is_admin: true, name: "Admin", email: "admin@example.org")
    email = admin_commenter.email
    blogpost = create(:post)
    post :create, params: valid_comment_params(post_id: blogpost.id).merge(commenter: {email: email})
    comment = assigns(:comment)
    assert_nil comment.commenter
    assert_not_equal admin_commenter, comment.commenter
    assert_not comment.send_email
  end

  test "hide comment with admin's email created by public user" do
    admin_commenter = Commenter.create!(is_admin: true, name: "Admin", email: "admin@example.org")
    email = admin_commenter.email
    blogpost = create(:post)
    post :create, params: valid_comment_params(post_id: blogpost.id).merge(commenter: {email: email})
    comment = assigns(:comment)
    assert_not comment.approved
  end

  test "hide comment if email is in restricted domain" do
    blogpost = create(:post)
    post :create, params: valid_comment_params(post_id: blogpost.id).merge(commenter: {email: "vasya@localhost.localdomain"})
    comment = assigns(:comment)
    assert_not_nil comment.commenter
    assert_not comment.approved
    assert_not comment.send_email
  end

  test "empty email should not trigger send_email" do
    post :create, params: valid_comment_params.merge(commenter: {email: " "})

    comment = assigns(:comment)
    assert_redirected_to public_comment_path(comment)
    assert_not_predicate comment, :send_email
  end

  test "valid response when comment invalid (No JS)" do
    assert_difference("Comment.count", 0) do
      post :create, params: valid_comment_params(body: "")
    end

    assert_response :success
    assert_template "comments/reply"
  end

  test "valid response when comment invalid (xhr)" do
    assert_difference("Comment.count", 0) do
      post :create, params: valid_comment_params(body: ""), xhr: true
    end

    assert_response 422
  end

  test "request unsubscribe" do
    comment = FactoryBot.create(:comment, send_email: true, unsubscribe_token: "Aaaaaaa")
    get :unsubscribe_request, params: {token: "Aaaaaaa"}
    assert_response :success
    assert assigns(:comment)
  end

  test "post unsubscribe" do
    FactoryBot.create(:comment, send_email: true, unsubscribe_token: "Aaaaaaa")
    post :unsubscribe_submit, params: {token: "Aaaaaaa"}
    assert_response :success
    comment =  assigns(:comment)
    assert_not comment.send_email
  end

end
