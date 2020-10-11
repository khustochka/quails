# frozen_string_literal: true

require 'test_helper'

class VideoTest < ActiveSupport::TestCase

  test 'do not save video without youtube id' do
    video = build(:video, youtube_id: '')
    assert_not video.save, "Record saved while expected to fail."
  end

  test 'properly dump and load thumbnail' do
    video = build(:video)
    assert_equal :youtube, video.assets_cache.externals.first.type
  end

  test 'create thumbnail when video is created' do
    obs = create(:observation)
    video = Video.create!(slug: 'video2', external_id: 'Aaaa1111', observations: [obs])
    assert_predicate video.assets_cache.externals, :present?
  end

  test 'change thumbnail when youtube id is updated' do
    video = create(:video)

    video.update(youtube_id: 'Zzzzz33333')

    assert video.assets_cache.externals.first.url.include?('Zzzzz33333')
  end

end
