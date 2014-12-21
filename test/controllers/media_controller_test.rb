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

end
