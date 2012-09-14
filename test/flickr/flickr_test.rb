require 'test_helper'

class FlickrTest < ActiveSupport::TestCase

  include FlickrApp

  test 'can find private flickr photos (auth success)' do
    FlickrApp.configured?
    assert_present flickr.photos.getInfo(photo_id: '3210846200')
  end

end
