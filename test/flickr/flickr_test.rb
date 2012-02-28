require 'test_helper'

class FlickrTest < ActiveSupport::TestCase

  test 'can find private flickr photos (auth success)' do
    flickr.photos.getInfo(photo_id: '3210846200').should_not be_blank
  end

end
