require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  setup do
    @obs = Factory.create(:observation)
    @image = Factory.build(:image)
    @image.observations << @obs
    @image.save
  end

  should "get index" do
    login_as_admin
    get :index
    assert_response :success
    assert_not_nil assigns(:images)
  end

  should "get new" do
    login_as_admin
    get :new
    assert_response :success
  end

  should "create image with one observation" do
    login_as_admin
    new_attr = @image.attributes.dup
    new_attr[:observation_ids] = [@obs.id]
    new_attr['code'] = 'new_img_code'
    assert_difference('Image.count') do
      post :create, :image => new_attr
    end

    assert_redirected_to public_image_path(assigns(:image))
  end

  should "create image with several observations" do
    login_as_admin
    obs2 = Factory.create(:observation, :species => Species.find_by_code('lancol'))
    obs3 = Factory.create(:observation, :species => Species.find_by_code('jyntor'))
    new_attr = @image.attributes.dup
    new_attr[:observation_ids] = [@obs.id, obs2.id, obs3.id]
    new_attr['code'] = 'new_img_code'
    assert_difference('Image.count') do
      post :create, :image => new_attr
    end

    assert_redirected_to public_image_path(assigns(:image))
  end

  should "not create image with no observations" do
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

  should "show image" do
    get :show, @image.to_url_params
    assert_response :success
  end

  should "get edit" do
    login_as_admin
    get :edit, :id => @image.to_param
    assert_response :success
  end

  should "update image" do
    login_as_admin
    new_attr = @image.attributes.dup
    new_attr['code'] = 'new_code'
    put :update, :id => @image.to_param, :image => new_attr
    assert_redirected_to public_image_path(assigns(:image))
  end

  should "not update image with no observations" do
    login_as_admin
    new_attr = @image.attributes.dup
    new_attr['code'] = 'new_img_code'
    new_attr[:observation_ids] = []
    put :update, :id => @image.to_param, :image => new_attr
    assert_equal ['provide at least one observation'], assigns(:image).errors[:base]
    assert_template :edit
  end

  should "destroy image" do
    login_as_admin
    assert_difference('Image.count', -1) do
      delete :destroy, :id => @image.to_param
    end

    assert_redirected_to images_path
  end
end
