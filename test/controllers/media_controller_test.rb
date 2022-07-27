# frozen_string_literal: true

require "test_helper"

class MediaControllerTest < ActionController::TestCase
  setup do
    @image = create(:image)
    @video = create(:video)
    @spot = create(:spot)
    # assert species(:pasdom).image
    # @obs = @image.observations.first
  end

  test "media strip with photos and videos (for the map)" do
    post :strip, xhr: true, params: { _json: [@image.id, @video.id] }
    assert assigns(:strip_media)
  end

  test "unmapped" do
    image2 = create(:image, spot_id: @spot.id)
    login_as_admin
    get :unmapped
    result = assigns(:media).map(&:id)
    assert_includes result, @image.id
    assert_includes result, @video.id
    assert_not_includes result, image2.id
  end

  test "half-mapped" do
    image2 = create(:image, spot_id: @spot.id)
    login_as_admin
    get :unmapped, params: { half: true }
    # result = assigns(:media).map(&:id)
    # assert result.include?(@image.id)
    # assert result.include?(@video.id)
    # assert_not_includes result, image2.id
  end
end
