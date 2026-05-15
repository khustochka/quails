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
      post :create, params: { post: attributes_for(:post) }
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
    get :edit, params: { id: blogpost.to_param }
    assert_response :success
    assert_select "a[href='#{public_post_path(blogpost)}']", true
  end

  test "update post" do
    blogpost = create(:post)
    blogpost.title = "Changed title"
    login_as_admin
    put :update, params: { id: blogpost.to_param, post: blogpost.attributes.except("lj_data") }
    assert_redirected_to public_post_path(assigns(:post))
  end

  test "do not update post with invalid attribute" do
    blogpost = create(:post)
    blogpost.title = ""
    login_as_admin
    put :update, params: { id: blogpost.to_param, post: blogpost.attributes.except("lj_data") }
    assert_template :form
  end

  test "do not update post with invalid slug" do
    blogpost = create(:post)
    post_attr = blogpost.attributes.except("lj_data")
    post_attr["slug"] = ""
    login_as_admin
    put :update, params: { id: blogpost.to_param, post: post_attr }
    assert_template :form
    assert_select "form[action='#{post_path(blogpost)}']"
  end

  test "destroy post" do
    blogpost = create(:post)
    assert_difference("Post.count", -1) do
      login_as_admin
      delete :destroy, params: { id: blogpost.to_param }
    end
    assert_redirected_to blog_url
  end

  test "edit picks the right post by id when slug is shared across languages" do
    uk_post = create(:post, lang: "uk", slug: "shared-slug", title: "UK title")
    en_post = create(:post, lang: "en", slug: "shared-slug", title: "EN title")
    login_as_admin
    get :edit, params: { id: en_post.to_param }
    assert_response :success
    assert_equal en_post, assigns(:post)
    assert_not_equal uk_post, assigns(:post)
  end

  test "update affects only the post matching the id when slug is shared" do
    uk_post = create(:post, lang: "uk", slug: "shared-slug", title: "UK title")
    en_post = create(:post, lang: "en", slug: "shared-slug", title: "EN title")
    login_as_admin
    put :update, params: { id: en_post.to_param, post: { title: "EN updated" } }
    assert_equal "EN updated", en_post.reload.title
    assert_equal "UK title", uk_post.reload.title
  end

  test "destroy removes only the post matching the id when slug is shared" do
    uk_post = create(:post, lang: "uk", slug: "shared-slug")
    en_post = create(:post, lang: "en", slug: "shared-slug")
    login_as_admin
    assert_difference("Post.count", -1) do
      delete :destroy, params: { id: en_post.to_param }
    end
    assert_not Post.exists?(en_post.id)
    assert Post.exists?(uk_post.id)
  end

  test "edit shows links to existing siblings in other languages" do
    uk_post = create(:post, lang: "uk", slug: "shared-slug")
    en_post = create(:post, lang: "en", slug: "shared-slug")
    login_as_admin
    get :edit, params: { id: uk_post.to_param }
    assert_response :success
    assert_select "ul.admin-shortcuts a[href='#{edit_post_path(en_post)}']", text: /Edit EN/
  end

  test "edit shows Attach cards for any translation" do
    uk_post = create(:post, lang: "uk", slug: "shared-slug")
    login_as_admin
    get :edit, params: { id: uk_post.to_param }
    assert_response :success
    assert_select "h3#card_attach"
  end

  test "edit does not show sibling link for fallback (uk shown when only ru exists)" do
    ru_post = create(:post, lang: "ru", slug: "shared-slug")
    login_as_admin
    get :edit, params: { id: ru_post.to_param }
    assert_response :success
    # ru's localized_versions[:uk] falls back to ru itself — no sibling edit link should appear
    assert_select "ul.admin-shortcuts a", text: /Edit UK/, count: 0
    assert_select "ul.admin-shortcuts a", text: /Edit RU/, count: 0
  end

  test "edit shows Create translation link with post_core_id when sibling missing" do
    uk_post = create(:post, lang: "uk", slug: "shared-slug", topic: "NEWS")
    login_as_admin
    get :edit, params: { id: uk_post.to_param }
    assert_response :success
    expected = new_post_path(post: {
      post_core_id: uk_post.post_core_id,
      lang: :en,
    })
    assert_select "ul.admin-shortcuts a[href='#{expected}']", text: /Create translation in EN/
  end

  test "edit shows Create translation in UK when only en exists, but never RU" do
    en_post = create(:post, lang: "en", slug: "shared-slug")
    login_as_admin
    get :edit, params: { id: en_post.to_param }
    assert_response :success
    assert_select "ul.admin-shortcuts a", text: /Create translation in UK/, count: 1
    assert_select "ul.admin-shortcuts a", text: /Create translation in RU/, count: 0
  end

  test "edit does not show Create translation link for language that already exists" do
    uk_post = create(:post, lang: "uk", slug: "shared-slug")
    create(:post, lang: "en", slug: "shared-slug")
    login_as_admin
    get :edit, params: { id: uk_post.to_param }
    assert_response :success
    assert_select "ul.admin-shortcuts a", text: /Create translation in EN/, count: 0
    assert_select "ul.admin-shortcuts a", text: /Create translation in UK/, count: 0
  end

  test "edit considers private siblings (uses available_posts)" do
    uk_post = create(:post, lang: "uk", slug: "shared-slug", status: "PRIV")
    en_post = create(:post, lang: "en", slug: "shared-slug", status: "PRIV")
    login_as_admin
    get :edit, params: { id: uk_post.to_param }
    assert_response :success
    assert_select "ul.admin-shortcuts a[href='#{edit_post_path(en_post)}']", text: /Edit EN/
  end

  test "new pre-fills form fields from seed params (new core)" do
    login_as_admin
    get :new, params: { post: { lang: "en", slug: "kyiv-trip" } }
    assert_response :success
    post = assigns(:post)
    assert_equal "en", post.lang
    assert_equal "kyiv-trip", post.slug
    assert_equal "PRIV", post.status
    assert_equal "OBSR", post.topic
  end

  test "new with post_core_id seeds translation against existing core" do
    existing = create(:post, lang: "uk", slug: "shared-slug", topic: "NEWS")
    login_as_admin
    get :new, params: { post: { lang: "en", post_core_id: existing.post_core_id } }
    assert_response :success
    post = assigns(:post)
    assert_equal existing.post_core_id, post.post_core_id
    assert_equal "shared-slug", post.slug
    assert_equal "NEWS", post.topic
  end

  test "redirect post to correct URL if year and month are incorrect" do
    blogpost = create(:post, face_date: "2007-12-06 13:14:15")
    get :show, params: { id: blogpost.slug, year: 2010, month: "01" }
    assert_redirected_to public_post_path(blogpost)
    assert_response :moved_permanently
  end

  # auth tests

  test "protect new with authentication" do
    assert_raise(ActionController::RoutingError) { get :new }
    # assert_response 404
  end

  test "protect edit with authentication" do
    blogpost = create(:post)
    assert_raise(ActionController::RoutingError) { get :edit, params: { id: blogpost.to_param } }
    # assert_response 404
  end

  test "protect create with authentication" do
    blogpost = create(:post)
    assert_raise(ActionController::RoutingError) { post :create, params: { post: blogpost.attributes } }
    # assert_response 404
  end

  test "protect update with authentication" do
    blogpost = create(:post)
    blogpost.title = "Changed title"
    assert_raise(ActionController::RoutingError) { put :update, params: { id: blogpost.to_param, post: blogpost.attributes } }
    # assert_response 404
  end

  test "protect destroy with authentication" do
    blogpost = create(:post)
    assert_raise(ActionController::RoutingError) { delete :destroy, params: { id: blogpost.to_param } }
    # assert_response 404
  end

  test "proper link options" do
    blogpost = create(:post)
    assert_equal show_post_path(blogpost.to_url_params.merge({ anchor: "comments" })), public_post_path(blogpost, anchor: "comments")
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

  test "correct species link in post body (default locale)" do
    blogpost = create(:post, status: "NIDX", body: "{{House Sparrow|Passer domesticus}}")
    get :show, params: blogpost.to_url_params
    html = response.parsed_body
    link = html.css("a.sp_link").first
    assert_equal "/species/Passer_domesticus", link[:href]
  end

  test "correct species link in post body (English locale)" do
    blogpost = create(:post, slug: "some-post", status: "NIDX", body: "{{House Sparrow|Passer domesticus}}", lang: "en")
    get :show, params: blogpost.to_url_params.merge(locale: :en)
    html = response.parsed_body
    link = html.css("a.sp_link").first
    assert_equal "/en/species/Passer_domesticus", link[:href]
  end

  test "redirect legacy -en slug to canonical slug with 301" do
    blogpost = create(:post, slug: "kyiv-trip", legacy_slug: "kyiv-trip-en", lang: "en")
    get :show, params: { id: "kyiv-trip-en", year: blogpost.year, month: blogpost.month, locale: :en }
    assert_redirected_to public_post_path(blogpost)
    assert_response :moved_permanently
  end

  test "show post by canonical slug when legacy slug also exists" do
    blogpost = create(:post, slug: "kyiv-trip", legacy_slug: "kyiv-trip-en", lang: "en")
    get :show, params: blogpost.to_url_params.merge(locale: :en)
    assert_response :success
  end

  test "show dedicated uk post when uk locale requested" do
    uk_post = create(:post, slug: "kyiv-trip", lang: "uk")
    ru_post = create(:post, slug: "kyiv-trip", lang: "ru")
    get :show, params: uk_post.to_url_params.merge(locale: :uk)
    assert_equal uk_post, assigns(:post)
  end

  test "fall back to ru post when uk locale requested but only ru exists" do
    ru_post = create(:post, slug: "kyiv-trip", lang: "ru")
    get :show, params: ru_post.to_url_params
    assert_equal ru_post, assigns(:post)
  end
end
