require 'test_helper'

class FlickrTest < ActiveSupport::TestCase

  test 'can find private flickr photos (auth success)' do
    flickr.photos.search(user_id: '8289389@N04', privacy_filter: 5).should_not be_blank
  end

end
