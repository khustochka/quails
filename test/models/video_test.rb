require 'test_helper'

class VideoTest < ActiveSupport::TestCase

  test 'do not save video without youtube id' do
    video = build(:video, youtube_id: '')
    assert_raise(ActiveRecord::RecordInvalid) { video.save! }
  end

end
