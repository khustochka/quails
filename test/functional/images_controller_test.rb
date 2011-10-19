require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  setup do
    @obs = FactoryGirl.create(:observation)
    @image = FactoryGirl.create(:image, :observations => [@obs])
  end

  test "get index" do
    login_as_admin
    get :index
    assert_response :success
    assert_not_nil assigns(:images)
  end

  test "get new" do
    login_as_admin
    get :new
    assert_response :success
  end

  test "create image with one observation" do
    login_as_admin
    new_attr = @image.attributes.dup
    new_attr[:observation_ids] = [@obs.id]
    new_attr['code'] = 'new_img_code'
    assert_difference('Image.count') do
      post :create, :image => new_attr
    end

    assert_redirected_to public_image_path(assigns(:image))
  end

  test "create image with several observations" do
    login_as_admin
    obs2 = FactoryGirl.create(:observation, :species => seed(:lancol))
    obs3 = FactoryGirl.create(:observation, :species => seed(:jyntor))
    new_attr = @image.attributes.dup
    new_attr[:observation_ids] = [@obs.id, obs2.id, obs3.id]
    new_attr['code'] = 'new_img_code'
    assert_difference('Image.count') do
      post :create, :image => new_attr
    end

    assert_redirected_to public_image_path(assigns(:image))
  end

  test "should not create image with no observations" do
    login_as_admin
    new_attr = @image.attributes.dup
    new_attr['code'] = 'new_img_code'
    new_attr[:observation_ids] = []
    assert_difference('Image.count', 0) do
      post :create, :image => new_attr
    end
    assert_equal ['provide at least one observation'], assigns(:image).errors[:base]
    assert_template :new
  end

  test "show image" do
    get :show, @image.to_url_params
    assert_response :success
  end

  test "get edit" do
    login_as_admin
    get :edit, :id => @image.to_param
    assert_response :success
  end

  test "update image" do
    login_as_admin
    new_attr = @image.attributes
    new_attr['code'] = 'new_code'
    new_attr[:observation_ids] = @image.observation_ids
    put :update, :id => @image.to_param, :image => new_attr
    assert_redirected_to public_image_path(assigns(:image))
  end

  test "should not update image with no observations" do
    login_as_admin
    new_attr = @image.attributes.dup
    new_attr['code'] = 'new_img_code'
    new_attr[:observation_ids] = []
    put :update, :id => @image.to_param, :image => new_attr
    assert_equal ['provide at least one observation'], assigns(:image).errors[:base]
    assert_template :edit
  end

  test "destroy image" do
    login_as_admin
    assert_difference('Image.count', -1) do
      delete :destroy, :id => @image.to_param
    end

    assert_redirected_to images_path
  end

  # TODO: all 'incognita' should be records in the DB (like Passer sp.)
  test 'Image page can be shown for Avis incognita photo as well' do
    observation = FactoryGirl.create(:observation, :species_id => 0)
    img = FactoryGirl.create(:image, :code => 'picture-of-the-unknown', :observations => [observation])
    get :show, img.to_url_params
  end
end
