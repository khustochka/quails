# frozen_string_literal: true

require "test_helper"

class PostsControllerTest < ActionController::TestCase

  test "get new" do
    login_as_admin
    get :new
    assert_response :success
  end

  test "create post" do
    assert_difference("Post.count") do
      login_as_admin
      post :create, params: {post: attributes_for(:post)}
    end
    assert_redirected_to public_post_path(assigns(:post))
  end

  test "show post" do
    blogpost = create(:post)
    get :show, params: blogpost.to_url_params
    assert_response :success
  end

  test "show post with images (and species, which is new)" do
    blogpost = create(:post)
    create(:image, observations: [create(:observation, card: create(:card, post: blogpost))])
    get :show, params: blogpost.to_url_params
    assert_response :success
  end

  test "show approved comment in the post" do
    comment = create(:comment)
    get :show, params: comment.post.to_url_params
    assert_response :success
    assert_select ".comment_box h6.name", text: comment.name
  end

  test "do not show unapproved comment to user" do
    comment = create(:comment)
    comment.update_column(:approved, false)
    get :show, params: comment.post.to_url_params
    assert_response :success
    assert_select ".comment_box h6.name", text: comment.name, count: 0
  end

  test "show unapproved comment to admin" do
    login_as_admin
    comment = create(:comment)
    comment.update_column(:approved, false)
    get :show, params: comment.post.to_url_params
    assert_response :success
    assert_select ".comment_box h6.name", text: comment.name
  end

  test "sanitize user web page URL in the comment" do
    comment = create(:comment, url: "javascript:alert('1')", name: "Vasya")
    get :show, params: comment.post.to_url_params
    assert_response :success
    assert_select ".comment_box h6.name", text: comment.name
    assert_select ".comment_box h6.name a", 0
  end

  test "species list in the post properly ordered" do
    # Dummy swap of two species
    max_index = Species.maximum(:index_num)
    min_index = Species.minimum(:index_num)
    sp1 = Species.find_by(index_num: min_index)
    sp2 = Species.find_by(index_num: max_index)
    sp1.update(index_num: max_index)
    sp2.update(index_num: min_index)

    blogpost = create(:post)
    create(:observation, taxon: sp2.main_taxon, post: blogpost)
    create(:observation, taxon: sp1.main_taxon, post: blogpost)

    get :show, params: blogpost.to_url_params
    assert_equal [sp2, sp1], assigns(:post).species
  end

  test "get edit" do
    blogpost = create(:post)
    login_as_admin
    get :edit, params: {id: blogpost.to_param}
    assert_response :success
    assert_select "a[href='#{public_post_path(blogpost)}']", true
  end

  test "update post" do
    blogpost = create(:post)
    blogpost.title = "Changed title"
    login_as_admin
    put :update, params: {id: blogpost.to_param, post: blogpost.attributes.except("lj_data")}
    assert_redirected_to public_post_path(assigns(:post))
  end

  test "do not update post with invalid attribute" do
    blogpost = create(:post)
    blogpost.title = ""
    login_as_admin
    put :update, params: {id: blogpost.to_param, post: blogpost.attributes.except("lj_data")}
    assert_template :form
  end

  test "do not update post with invalid slug" do
    blogpost = create(:post)
    post_attr = blogpost.attributes.except("lj_data")
    post_attr["slug"] = ""
    login_as_admin
    put :update, params: {id: blogpost.slug, post: post_attr}
    assert_template :form
    assert_select "form[action='#{post_path(blogpost)}']"
  end

  test "destroy post" do
    blogpost = create(:post)
    assert_difference("Post.count", -1) do
      login_as_admin
      delete :destroy, params: {id: blogpost.to_param}
    end
    assert_redirected_to blog_url
  end

  test "redirect post to correct URL if year and month are incorrect" do
    blogpost = create(:post, face_date: "2007-12-06 13:14:15")
    get :show, params: {id: blogpost.slug, year: 2010, month: "01"}
    assert_redirected_to public_post_path(blogpost)
    assert_response 301
  end

  # auth tests

  test "protect new with authentication" do
    assert_raise(ActionController::RoutingError) { get :new }
    # assert_response 404
  end

  test "protect edit with authentication" do
    blogpost = create(:post)
    assert_raise(ActionController::RoutingError) { get :edit, params: {id: blogpost.to_param} }
    # assert_response 404
  end

  test "protect create with authentication" do
    blogpost = create(:post)
    assert_raise(ActionController::RoutingError) { post :create, params: {post: blogpost.attributes} }
    # assert_response 404
  end

  test "protect update with authentication" do
    blogpost = create(:post)
    blogpost.title = "Changed title"
    assert_raise(ActionController::RoutingError) { put :update, params: {id: blogpost.to_param, post: blogpost.attributes} }
    # assert_response 404
  end

  test "protect destroy with authentication" do
    blogpost = create(:post)
    assert_raise(ActionController::RoutingError) { delete :destroy, params: {id: blogpost.to_param} }
    # assert_response 404
  end

  test "proper link options" do
    blogpost = create(:post)
    assert_equal show_post_path(blogpost.to_url_params.merge({anchor: "comments"})), public_post_path(blogpost, anchor: "comments")
  end

  test "show draft posts page to admin" do
    blogpost1 = create(:post, face_date: "2007-12-06 13:14:15", status: "PRIV")
    blogpost2 = create(:post, face_date: "2008-11-06 13:14:15")
    login_as_admin
    get :hidden
    assert_includes(assigns(:posts), blogpost1)
    assert_not_includes(assigns(:posts), blogpost2)
  end

  test "show hidden post to admin" do
    blogpost1 = create(:post, face_date: "2007-12-06 13:14:15", status: "PRIV")
    login_as_admin
    get :show, params: blogpost1.to_url_params
    assert_response :success
  end

  test "do not show draft posts page to user" do
    blogpost1 = create(:post, face_date: "2007-12-06 13:14:15", status: "PRIV")
    blogpost2 = create(:post, face_date: "2008-11-06 13:14:15")
    assert_raise(ActionController::RoutingError) { get :hidden }
  end

  test "do not show hidden post to user" do
    blogpost1 = create(:post, face_date: "2007-12-06 13:14:15", status: "PRIV")
    assert_raise(ActiveRecord::RecordNotFound) { get :show, params: blogpost1.to_url_params }
  end

  test "do not show NOINDEX post on drafts page" do
    blogpost = create(:post, status: "NIDX")
    login_as_admin
    get :hidden
    assert_not_includes(assigns(:posts), blogpost)
  end

  test "show NOINDEX post page to user" do
    blogpost = create(:post, status: "NIDX")
    login_as_admin
    get :show, params: blogpost.to_url_params
    assert_response :success
    assert_equal "NOINDEX", assigns(:robots)
  end

  test "show NOINDEX post page to admin" do
    blogpost = create(:post, status: "NIDX")
    login_as_admin
    get :show, params: blogpost.to_url_params
    assert_response :success
    assert_equal "NOINDEX", assigns(:robots)
  end
end
