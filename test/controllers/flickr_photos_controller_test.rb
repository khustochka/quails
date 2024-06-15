# frozen_string_literal: true

require "test_helper"

class FlickrPhotosControllerTest < ActionController::TestCase
  # test "should not allow duplicated flickr id" do
  #
  #   img1 = create(:image, flickr_id: "aaa111")
  #   img2 = create(:image, flickr_id: "bbb222")
  #
  #   login_as_admin
  #   post :create, id: img1.slug, flickr_id: img2.flickr_id, format: :json
  #
  #   assert 422, response.code
  #
  # end

  test "#unflickred" do
    img1 = create(:image)
    login_as_admin
    get :unflickred
    assert_response :success
  end

  test "#show for unflickred image" do
    img1 = create(:image)

    login_as_admin
    get :show, params: { id: img1.slug }
    assert_response :success
  end

  test "#show for flickred image" do
    img1 = create(:image_on_flickr)

    login_as_admin
    get :show, params: { id: img1.slug }
    assert_response :success
  end
end
