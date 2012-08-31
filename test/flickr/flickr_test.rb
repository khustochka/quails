require 'test_helper'

class FlickrTest < ActiveSupport::TestCase

  test 'can find private flickr photos (auth success)' do
    assert_present flickr.photos.getInfo(photo_id: '3210846200')
  end

end
