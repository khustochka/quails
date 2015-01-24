require 'test_helper'

class MediaControllerTest < ActionController::TestCase
  setup do
    @image = create(:image)
    @video = create(:video)
    #assert seed(:pasdom).image
    #@obs = @image.observations.first
  end

  test 'media strip with photos and videos (for the map)' do
    xhr :post, :strip, _json: [@image.id, @video.id]
    assert assigns(:media)
  end

  test 'unmapped' do
    spot = create(:spot)
    image2 = create(:image, spot_id: spot.id)
    login_as_admin
    get :unmapped
    result = assigns(:media).map(&:id)
    assert result.include?(@image.id)
    assert result.include?(@video.id)
    assert_not result.include?(image2.id)
  end

  test 'half-mapped' do
    spot = create(:spot)
    image2 = create(:image, spot_id: spot.id)
    login_as_admin
    get :unmapped, half: true
    # result = assigns(:media).map(&:id)
    # assert result.include?(@image.id)
    # assert result.include?(@video.id)
    # assert_not result.include?(image2.id)
  end

end
