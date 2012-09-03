require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  setup do
    @image = create(:image)
    @obs = @image.observations.first
  end

  test "get index" do
    login_as_admin
    get :index
    assert_response :success
    assert_not_nil assigns(:images)
  end

  test "get photostream" do
    get :photostream
    assert_response :success
    assert_not_nil assigns(:images)
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
    new_attr = @image.attributes.dup
    new_attr['slug'] = 'new_img_slug'
    assert_difference('Image.count') do
      post :create, image: new_attr, obs: [@obs.id]
    end

    assert_redirected_to public_image_path(assigns(:image))
  end

  test "create image with several observations" do
    login_as_admin
    obs2 = create(:observation, species: seed(:lancol))
    obs3 = create(:observation, species: seed(:jyntor))
    new_attr = @image.attributes.dup
    new_attr['slug'] = 'new_img_slug'
    assert_difference('Image.count') do
      post :create, image: new_attr, obs: [@obs.id, obs2.id, obs3.id]
    end

    assert_redirected_to public_image_path(assigns(:image))
  end

  test "show image" do
    get :show, @image.to_url_params
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
    assert_redirected_to public_image_path(assigns(:image))
  end

  test "image removed from map if it is tied to another observation" do
    spot = create(:spot)
    obs = spot.observation
    img = create(:image, observation_ids: [obs.id], spot: spot)
    obs2 = create(:observation)
    login_as_admin
    put :update, id: img.to_param, obs: [obs2.id], image: img.attributes
    img.reload
    assert_blank img.spot
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
    get :show, img.to_url_params
  end

  test 'do not show link to private post to public user on image page' do
    blogpost = create(:post, status: 'PRIV')
    @obs.post = blogpost
    @obs.save!
    get :show, @image.to_url_params
    assert_select "a[href=#{public_post_path(blogpost)}]", false
  end

  test 'show link to public post to public user on image page' do
    blogpost = create(:post)
    @obs.post = blogpost
    @obs.save!
    get :show, @image.to_url_params
    assert_select "a[href=#{public_post_path(blogpost)}]"
  end
end
