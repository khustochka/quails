# frozen_string_literal: true

require "test_helper"

class PostCoresControllerTest < ActionController::TestCase
  test "get new" do
    login_as_admin
    get :new
    assert_response :success
  end

  test "new requires admin" do
    assert_raise(ActionController::RoutingError) { get :new }
  end

  test "create succeeds and redirects to new post for translation" do
    login_as_admin
    assert_difference("PostCore.count") do
      post :create, params: { post_core: { slug: "kyiv-trip", topic: "OBSR" } }
    end
    core = PostCore.find_by(slug: "kyiv-trip")
    assert_redirected_to new_post_path(post: { post_core_id: core.id, lang: I18n.locale })
  end

  test "create rejects duplicate slug" do
    create(:post_core, slug: "kyiv-trip")
    login_as_admin
    assert_no_difference("PostCore.count") do
      post :create, params: { post_core: { slug: "kyiv-trip", topic: "OBSR" } }
    end
    assert_template :form
  end

  test "get edit" do
    core = create(:post_core)
    login_as_admin
    get :edit, params: { id: core.id }
    assert_response :success
  end

  test "edit lists existing translations and create links for missing ones" do
    core = create(:post_core, slug: "shared")
    uk_post = create(:post, post_core: core, lang: "uk")
    login_as_admin
    get :edit, params: { id: core.id }
    assert_response :success
    assert_select "a[href='#{edit_post_path(uk_post)}']", text: /Edit UK/
    assert_select "a[href='#{new_post_path(post: { post_core_id: core.id, lang: "en" })}']", text: /Create EN/
  end

  test "update changes shared fields and redirects to posts index" do
    core = create(:post_core, slug: "old-slug", topic: "OBSR")
    login_as_admin
    put :update, params: { id: core.id, post_core: { slug: "new-slug", topic: "NEWS" } }
    core.reload
    assert_equal "new-slug", core.slug
    assert_equal "NEWS", core.topic
    assert_redirected_to posts_path
  end

  test "update rejects invalid slug" do
    core = create(:post_core, slug: "valid-slug")
    login_as_admin
    put :update, params: { id: core.id, post_core: { slug: "" } }
    assert_template :form
    assert_equal "valid-slug", core.reload.slug
  end

  test "destroy removes an empty core" do
    core = create(:post_core)
    login_as_admin
    assert_difference("PostCore.count", -1) do
      delete :destroy, params: { id: core.id }
    end
    assert_redirected_to posts_path
  end

  test "destroy is prevented when translations exist" do
    core = create(:post_core)
    create(:post, post_core: core, lang: "uk")
    login_as_admin
    assert_no_difference("PostCore.count") do
      assert_no_difference("Post.count") do
        delete :destroy, params: { id: core.id }
      end
    end
    assert_redirected_to edit_post_core_path(core)
    assert_match(/posts/i, flash[:alert].to_s)
  end
end
