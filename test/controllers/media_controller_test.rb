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

  test "strip with offset and limit returns a page of results" do
    images = create_list(:image, 3)
    ids = images.map(&:id)

    post :strip, xhr: true, params: { _json: ids, offset: 0, limit: 2 }
    assert_equal 2, assigns(:strip_media).size

    post :strip, xhr: true, params: { _json: ids, offset: 2, limit: 2 }
    assert_equal 1, assigns(:strip_media).size
  end

  test "strip without limit returns all results" do
    ids = [@image.id, @video.id]
    post :strip, xhr: true, params: { _json: ids }
    assert_equal 2, assigns(:strip_media).size
  end

  test "strip results are sorted chronologically" do
    card_old = create(:card, observ_date: "2020-01-01")
    card_new = create(:card, observ_date: "2024-06-15")
    obs_old = create(:observation, card: card_old)
    obs_new = create(:observation, card: card_new)
    image_new = create(:image, observations: [obs_new])
    image_old = create(:image, observations: [obs_old])

    post :strip, xhr: true, params: { _json: [image_new.id, image_old.id] }
    result_ids = assigns(:strip_media).map(&:id)
    assert_equal [image_old.id, image_new.id], result_ids
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
    assert_response :success
    # result = assigns(:media).map(&:id)
    # assert result.include?(@image.id)
    # assert result.include?(@video.id)
    # assert_not_includes result, image2.id
  end
end
