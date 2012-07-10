require 'test_helper'

class FlickrTest < ActiveSupport::TestCase

  test 'can find private flickr photos (auth success)' do
    expect(flickr.photos.getInfo(photo_id: '3210846200')).not_to be_blank
  end

end
