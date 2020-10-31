# frozen_string_literal: true

require "test_helper"

class VideoObservValidationTest < ActiveSupport::TestCase

  setup do
    @obs = create(:observation)
    @video = create(:video, observation_ids: [@obs.id])
  end

  test "does not update video with empty observation list" do
    new_attr = attributes_for(:video, slug: "new_video_slug").except(:observations)
    new_attr[:observations] = []
    assert_not @video.update(new_attr)
    assert @video.errors.present?
  end

  test "restores observation list if video was not saved due to its emptiness" do
    new_attr = @video.attributes # observations_ids are not in here
    new_attr["slug"] = "new_video_slug"
    new_attr[:observations] = []
    @video.update(new_attr)
    assert_equal @video.observation_ids, @video.observation_ids
  end

  test "does not restore former observation list if video was not saved not due to their emptiness" do
    new_obs = create(:observation)
    new_attr = @video.attributes # observations_ids are not in here
    new_attr["slug"] = ""
    new_attr[:observations] = [new_obs]
    @video.update(new_attr)
    assert_equal [new_obs.id], @video.observation_ids
  end

  test "excludes duplicated observations on video create" do
    new_attr = attributes_for(:video).except(:observations)
    new_attr["slug"] = "new_video_slug"
    new_attr[:observation_ids] = [@obs.id, @obs.id]
    video = Video.new
    assert_difference("Video.count", 1) do
      video.update(new_attr)
    end
    assert_empty video.errors
    assert_equal [@obs.id], video.observation_ids
  end

  test "excludes duplicated observation (existing) on video update" do
    new_attr = @video.attributes
    obs = create(:observation, card: @obs.card)
    new_attr[:observation_ids] = [@obs.id, @obs.id, obs.id]
    assert @video.update(new_attr)
    assert_empty @video.errors
    assert_equal 2, @video.observation_ids.count
  end

  test "excludes duplicated observation (new) on video update" do
    new_attr = @video.attributes
    obs = create(:observation, card: @obs.card)
    new_attr[:observation_ids] = [@obs.id, obs.id, obs.id]
    assert @video.update(new_attr)
    assert_empty @video.errors
    assert_equal 2, @video.observation_ids.count
  end

  test "does not create video with inconsistent observations (different date)" do
    obs1 = create(:observation, card: create(:card, observ_date: "2011-01-01"))
    obs2 = create(:observation, card: create(:card, observ_date: "2010-01-01"))
    new_attr = build(:video).attributes
    new_attr[:observation_ids] = [obs1.id, obs2.id]
    video = Video.new
    assert_difference("Video.count", 0) do
      video.update(new_attr)
    end
    assert_predicate video.errors, :present?
  end

  test "does not create video with inconsistent observations (different loc)" do
    obs1 = create(:observation, card: create(:card, locus: loci(:brovary)))
    obs2 = create(:observation, card: create(:card, locus: loci(:nyc)))
    new_attr = build(:video).attributes
    video = Video.new
    new_attr[:observation_ids] = [obs1.id, obs2.id]
    assert_difference("Video.count", 0) do
  video.update(new_attr)
end
    assert_predicate video.errors, :present?
  end

  test "does not update video with inconsistent observations" do
    obs1 = create(:observation, card: create(:card, observ_date: "2011-01-01"))
    obs2 = create(:observation, card: create(:card, observ_date: "2010-01-01"))
    new_attr = @video.attributes
    new_attr[:observation_ids] = [obs1.id, obs2.id]
    assert_not @video.update(new_attr)
    assert @video.errors.present?
  end

  test "preserves changed values if video failed to update with inconsistent observations" do
    obs1 = create(:observation, card: create(:card, observ_date: "2011-01-01"))
    obs2 = create(:observation, card: create(:card, observ_date: "2010-01-01"))
    new_attr = @video.attributes
    new_attr[:slug] = "newslug"
    new_attr[:observation_ids] = [obs1.id, obs2.id]
    assert_not @video.update(new_attr)
    assert @video.errors.present?
    assert_equal "newslug", @video.slug
  end

end
