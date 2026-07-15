# frozen_string_literal: true

require "test_helper"

class ImagesControllerTest < ActionController::TestCase
  def valid_image_attributes(attrs = {})
    default = { stored_image: fixture_file_upload("tules.jpg") }
    attributes_for(:image, default.merge(attrs))
  end

  setup do
    @image = create(:image)
    assert species(:pasdom).image
    @obs = @image.observations.first
  end

  test "get index" do
    get :index
    assert_response :success
    assert_not_empty assigns(:images)

    assert_select "a[href='#{image_path(@image)}']"
  end

  test "get front page in English" do
    create(:comment)
    get :index, params: { locale: "en" }
    assert_response :success
    assert_not_empty assigns(:images)
    assert_select "figcaption", text: @image.species[0].name_en
  end

  test "index thumbnails use direct urls with a redirect fallback when the flag is on" do
    image = create(:image_on_storage)
    image.thumbnail_variant.processed
    with_direct_variant_urls do
      get :index
      assert_response :success
      assert_select "figure.image_thumb " \
        "img[src*='/rails/active_storage/disk/']" \
        "[data-fallback-src*='/rails/active_storage/representations/redirect/']"
    end
  end

  test "index thumbnails use redirect urls when the flag is off" do
    image = create(:image_on_storage)
    image.thumbnail_variant.processed
    get :index
    assert_response :success
    assert_select "figure.image_thumb img[src*='/rails/active_storage/representations/redirect/']"
    assert_select "figure.image_thumb img[data-fallback-src]", count: 0
  end

  test "too big page number should return 404" do
    assert_raise ActiveRecord::RecordNotFound do
      get :index, params: { page: 7262 }
    end
  end

  test "show photos of multiple species" do
    tx1 = taxa(:pasdom)
    tx2 = taxa(:hirrus)
    card = create(:card, observ_date: "2008-07-01")
    obs1 = create(:observation, taxon: tx1, card: card)
    obs2 = create(:observation, taxon: tx2, card: card)
    img = create(:image, slug: "picture-of-the-shrike-and-the-wryneck", observations: [obs1, obs2])

    get :multiple_species
    assert_response :success
    assert_not_empty assigns(:images)

    assert_select "a[href='#{image_path(img)}']"
  end

  test "Birds of USA" do
    obs = create(:observation, card: create(:card, locus: loci(:nyc)))
    img = create(:image, observations: [obs])
    get :country, params: { country: "usa" }
    assert_response :success
    assert_predicate assigns(:thumbs), :present?, "Thumbnails must be present, were not."
    assert_select "a[href='#{image_path(img)}']"
  end

  test "Birds of UK" do
    uk = create(:locus, loc_type: "country", slug: "united_kingdom")
    london = create(:locus, parent: uk, slug: "london")
    obs = create(:observation, card: create(:card, locus: london))
    img = create(:image, observations: [obs])
    get :country, params: { country: "united_kingdom" }
    assert_response :success
    assert_predicate assigns(:thumbs), :present?
    assert_select "a[href='#{image_path(img)}']"
  end

  test "country gallery is paginated" do
    obs = create(:observation, card: create(:card, locus: loci(:nyc)))
    create(:image, observations: [obs])

    get :country, params: { country: "usa" }
    assert_response :success
    assert_respond_to assigns(:thumbs), :current_page
    assert_equal 1, assigns(:thumbs).current_page
    assert_equal ImagesController::PHOTOS_PER_PAGE, assigns(:thumbs).limit_value

    get :country, params: { country: "usa", page: 2 }
    assert_response :success
    assert_equal 2, assigns(:thumbs).current_page
  end

  test "country gallery redirects page 1 to unpaginated url" do
    get :country, params: { country: "usa", page: 1 }
    assert_redirected_to country_images_path(country: "usa")
  end

  test "get new" do
    login_as_admin
    get :new
    assert_response :success
  end

  test "create image with one observation" do
    login_as_admin
    new_attr = valid_image_attributes(slug: "new_img_slug").except(:observations)
    assert_difference("Image.count") do
      post :create, params: { image: new_attr, obs: [@obs.id] }
    end

    assert_redirected_to edit_map_image_path(assigns(:image))
  end

  test "create image with several observations" do
    login_as_admin
    obs2 = create(:observation, taxon: taxa(:pasdom), card: @obs.card)
    obs3 = create(:observation, taxon: taxa(:hirrus), card: @obs.card)
    new_attr = valid_image_attributes(slug: "new_img_slug").except(:observations)
    assert_difference("Image.count") do
      post :create, params: { image: new_attr, obs: [@obs.id, obs2.id, obs3.id] }
      image = assigns(:image)
      assert_empty image.errors
    end
    assert_redirected_to edit_map_image_path(assigns(:image))
  end

  test "do not save image without slug" do
    login_as_admin
    new_attr = valid_image_attributes(slug: "")
    assert_difference("Image.count", 0) do
      post :create, params: { image: new_attr, obs: [@obs.id] }
    end

    assert_template :form
  end

  test "do not save image with no observations" do
    login_as_admin
    new_attr = valid_image_attributes(slug: "new_img_slug")
    assert_difference("Image.count", 0) do
      post :create, params: { image: new_attr, obs: [] }
    end

    assert_template :form
  end

  test "do not save image with conflicting observations" do
    login_as_admin
    obs2 = create(:observation, card: create(:card, locus: loci(:kyiv)))
    obs3 = create(:observation, card: create(:card, locus: loci(:brovary)))
    new_attr = build(:image, slug: "new_img_slug").attributes.except("assets_cache")
    assert_difference("Image.count", 0) do
      post :create, params: { image: new_attr, obs: [obs2.id, obs3.id] }
    end

    assert_template :form
  end

  test "show image" do
    get :show, params: { id: @image.to_param }
    assert_response :success
  end

  test "image page shows en sibling post link in en locale" do
    core = create(:post_core)
    create(:post, post_core: core, lang: "uk")
    en_post = create(:post, post_core: core, lang: "en")
    @obs.update!(post_core: core)
    get :show, params: { id: @image.to_param, locale: :en }
    assert_response :success
    assert_select "a[href*='#{public_post_path(en_post, locale: :en)}']"
  end

  test "image page hides post link in en locale when no en sibling" do
    uk_post = create(:post, lang: "uk")
    @obs.update!(post_core: uk_post.post_core)
    get :show, params: { id: @image.to_param, locale: :en }
    assert_response :success
    assert_select "a[href*='#{public_post_path(uk_post)}']", count: 0
  end

  test "respond with JPG image" do
    get :show, params: { id: @image.to_param, format: :jpg }
    assert_response :redirect
  end

  test "get edit" do
    login_as_admin
    get :edit, params: { id: @image.to_param }
    assert_response :success
  end

  test "get map_edit" do
    login_as_admin
    get :map_edit, params: { id: @image.to_param }
    assert_response :success
  end

  test "update image" do
    login_as_admin
    new_attr = @image.attributes
    new_attr["slug"] = "new_slug"
    put :update, params: { id: @image.to_param, image: new_attr, obs: @image.observation_ids }
    assert_redirected_to edit_map_image_path(assigns(:image))
  end

  test "remove spot_id when changing image observation" do
    login_as_admin
    spot = create(:spot, observation_id: @image.observation_ids.first)
    @image.spot_id = spot.id
    @image.save!
    new_attr = @image.attributes
    obs = create(:observation)
    put :update, params: { id: @image.to_param, image: new_attr, obs: [obs.id] }
    @image.reload
    assert_not @image.spot_id, "Spot id should be nil"
  end

  test "do not remove spot_id when resaving image" do
    login_as_admin
    spot = create(:spot, observation_id: @image.observation_ids.first)
    @image.spot_id = spot.id
    @image.save!
    new_attr = @image.attributes
    put :update, params: { id: @image.to_param, image: new_attr, obs: @image.observation_ids }
    @image.reload
    assert @image.spot_id, "Spot id is nil"
  end

  test "do not remove spot_id when adding image observation" do
    login_as_admin
    spot = create(:spot, observation_id: @image.observation_ids.first)
    @image.spot_id = spot.id
    @image.save!
    new_attr = @image.attributes
    obs = create(:observation, card: @obs.card)
    put :update, params: { id: @image.to_param, image: new_attr, obs: @image.observation_ids.push(obs.id) }
    assert_predicate assigns(:image).errors, :blank?
    @image.reload
    assert @image.spot_id, "Spot id is nil"
  end

  test "do not remove spot_id when image change is not valid" do
    login_as_admin
    spot = create(:spot, observation_id: @image.observation_ids.first)
    @image.spot_id = spot.id
    @image.save!
    new_attr = @image.attributes
    obs1 = create(:observation)
    obs2 = create(:observation)
    put :update, params: { id: @image.to_param, image: new_attr, obs: [obs1.id, obs2.id] }
    assert_predicate assigns(:image).errors, :present?
    @image.reload
    assert @image.spot_id, "Spot id is nil"
  end

  test "update image spot via json" do
    spot = create(:spot)
    obs = spot.observation
    img = create(:image, observation_ids: [obs.id], spot: spot)
    spot2 = create(:spot, observation: obs)
    login_as_admin
    post :patch, params: { id: img.to_param, image: { spot_id: spot2.id } }, format: :json
    img.reload
    assert_equal spot2.id, img.spot_id
    assert_response :no_content
  end

  test "destroy image" do
    login_as_admin
    assert_difference("Image.count", -1) do
      delete :destroy, params: { id: @image.to_param }
    end

    assert_redirected_to localized_images_path
  end

  test "Image page can be shown for spuhs as well" do
    observation = create(:observation, taxon: taxa(:aves_sp))
    img = create(:image, slug: "picture-of-the-unknown", observations: [observation])
    get :show, params: { id: img }
  end

  test "do not show link to private post to public user on image page" do
    blogpost = create(:post, status: "PRIV")
    @obs.post_core = blogpost.post_core
    @obs.save!
    get :show, params: { id: @image }
    assert_select "a[href='#{public_post_path(blogpost)}']", false
  end

  test "show link to public post to public user on image page" do
    blogpost = create(:post)
    @obs.post_core = blogpost.post_core
    @obs.save!
    get :show, params: { id: @image.to_param }
    assert_select "a[href*='#{public_post_path(blogpost)}']"
  end

  test "show image in another locale" do
    get :show, params: { id: @image.to_param, locale: :en }
    assert_response :success
  end

  test "image in another locale - correct canonical link" do
    get :show, params: { id: @image.to_param, locale: :en }
    assert_equal localized_image_url(locale: :en, id: @image.to_param), css_select("head link[rel=canonical]").attribute("href").value
  end
end
