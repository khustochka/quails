require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  setup do
    @image = create(:image)
    assert seed(:pasdom).image
    @obs = @image.observations.first
  end

  test "get index" do
    get :index
    assert_response :success
    assert_not_empty assigns(:images)

    assert_select "a[href=#{image_path(@image)}]"
  end

  test "crazy page number should return 404" do
    assert_raise ActiveRecord::RecordNotFound do
      get :index, page: 7262
    end
  end

  test "show photos of multiple species" do
    sp1 = seed(:lancol)
    sp2 = seed(:jyntor)
    card = create(:card, observ_date: "2008-07-01")
    obs1 = create(:observation, species: sp1, card: card)
    obs2 = create(:observation, species: sp2, card: card)
    img = create(:image, slug: 'picture-of-the-shrike-and-the-wryneck', observations: [obs1, obs2])

    get :multiple_species
    assert_response :success
    assert_not_empty assigns(:images)

    assert_select "a[href=#{image_path(img)}]"
  end

  test "get new" do
    login_as_admin
    get :new
    assert_response :success
  end

  test "get observations for an image" do
    login_as_admin
    get :observations, id: @image.id, format: :json
    assert_response :success
    assert_equal Mime::JSON, response.content_type
  end

  test "create image with one observation" do
    login_as_admin
    new_attr = attributes_for(:image, slug: 'new_img_slug').except(:observations)
    assert_difference('Image.count') do
      post :create, image: new_attr, obs: [@obs.id]
    end

    assert_redirected_to edit_map_image_path(assigns(:image))
  end

  test "create image with several observations" do
    login_as_admin
    obs2 = create(:observation, species: seed(:lancol), card: @obs.card)
    obs3 = create(:observation, species: seed(:jyntor), card: @obs.card)
    new_attr = attributes_for(:image, slug: 'new_img_slug').except(:observations)
    assert_difference('Image.count') do
      post :create, image: new_attr, obs: [@obs.id, obs2.id, obs3.id]
      image = assigns(:image)
      refute image.errors.any?
    end
    assert_redirected_to edit_map_image_path(assigns(:image))
  end

  test "do not save image without slug" do
    login_as_admin
    new_attr = build(:image, slug: '').attributes.except('assets_cache')
    assert_difference('Image.count', 0) do
      post :create, image: new_attr, obs: [@obs.id]
    end

    assert_template :form
  end

  test "do not save image with no observations" do
    login_as_admin
    new_attr = build(:image, slug: 'new_img_slug').attributes
    assert_difference('Image.count', 0) do
      post :create, image: new_attr, obs: []
    end

    assert_template :form
  end

  test "do not save image with conflicting observations" do
    login_as_admin
    obs2 = create(:observation, card: create(:card, locus: seed(:kiev)))
    obs3 = create(:observation, card: create(:card, locus: seed(:brovary)))
    new_attr = build(:image, slug: 'new_img_slug').attributes.except('assets_cache')
    assert_difference('Image.count', 0) do
      post :create, image: new_attr, obs: [obs2.id, obs3.id]
    end

    assert_template :form
  end

  test "show image" do
    get :show, id: @image.to_param
    assert_response :success
  end

  test "get edit" do
    login_as_admin
    get :edit, id: @image.to_param
    assert_response :success
  end

  test "get flickr_edit" do
    login_as_admin
    get :flickr_edit, id: @image.to_param
    assert_response :success
  end

  test "get unflickred" do
    login_as_admin
    get :unflickred
    assert_response :success
    assert_not_empty assigns(:images)

    assert_select "a[href=#{edit_flickr_image_path(@image)}]"
  end

  test "get map_edit" do
    login_as_admin
    get :map_edit, id: @image.to_param
    assert_response :success
  end

  test "update image" do
    login_as_admin
    new_attr = @image.attributes
    new_attr['slug'] = 'new_slug'
    put :update, id: @image.to_param, image: new_attr, obs: @image.observation_ids
    assert_redirected_to edit_map_image_path(assigns(:image))
  end

  test "remove spot_id when changing image observation" do
    login_as_admin
    spot = create(:spot, observation_id: @image.observation_ids.first)
    @image.spot_id = spot.id
    @image.save!
    new_attr = @image.attributes
    obs = create(:observation)
    put :update, id: @image.to_param, image: new_attr, obs: [obs.id]
    @image.reload
    refute @image.spot_id, "Spot id should be nil"
  end

  test "do not remove spot_id when resaving image" do
    login_as_admin
    spot = create(:spot, observation_id: @image.observation_ids.first)
    @image.spot_id = spot.id
    @image.save!
    new_attr = @image.attributes
    put :update, id: @image.to_param, image: new_attr, obs: @image.observation_ids
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
    put :update, id: @image.to_param, image: new_attr, obs: @image.observation_ids.push(obs.id)
    assert assigns(:image).errors.blank?
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
    put :update, id: @image.to_param, image: new_attr, obs: [obs1.id, obs2.id]
    assert assigns(:image).errors.present?
    @image.reload
    assert @image.spot_id, "Spot id is nil"
  end

  test "update image spot via json" do
    spot = create(:spot)
    obs = spot.observation
    img = create(:image, observation_ids: [obs.id], spot: spot)
    spot2 = create(:spot, observation: obs)
    login_as_admin
    post :patch, id: img.to_param, image: {spot_id: spot2.id}, format: :json
    img.reload
    assert_equal spot2.id, img.spot_id
    assert_response :success
    assert_equal Mime::JSON, response.content_type
  end

  test "image removed from map if it is tied to another observation" do
    spot = create(:spot)
    obs = spot.observation
    img = create(:image, observation_ids: [obs.id], spot: spot)
    obs2 = create(:observation)
    login_as_admin
    put :update, id: img.to_param, obs: [obs2.id], image: img.attributes
    img.reload
    assert img.spot.blank?
  end

  test "destroy image" do
    login_as_admin
    assert_difference('Image.count', -1) do
      delete :destroy, id: @image.to_param
    end

    assert_redirected_to images_path
  end

  test 'Image page can be shown for Avis incognita photo as well' do
    observation = create(:observation, species_id: 0)
    img = create(:image, slug: 'picture-of-the-unknown', observations: [observation])
    get :show, id: img
  end

  test 'do not show link to private post to public user on image page' do
    blogpost = create(:post, status: 'PRIV')
    @obs.post = blogpost
    @obs.save!
    get :show, id: @image
    assert_select "a[href=#{public_post_path(blogpost)}]", false
  end

  test 'show link to public post to public user on image page' do
    blogpost = create(:post)
    @obs.post = blogpost
    @obs.save!
    get :show, id: @image.to_param
    assert_select "a[href=#{public_post_path(blogpost)}]"
  end
end
