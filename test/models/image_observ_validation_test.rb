# frozen_string_literal: true

require "test_helper"

class ImageObservValidationTest < ActiveSupport::TestCase
  setup do
    @obs = create(:observation)
    @image = create(:image, observation_ids: [@obs.id])
  end

  test "does not update image with empty observation list" do
    new_attr = attributes_for(:image, slug: "new_img_slug").except(:observations)
    new_attr[:observations] = []
    assert_not @image.update(new_attr)
    assert_predicate @image.errors, :present?
  end

  test "restores observation list if image was not saved due to its emptiness" do
    new_attr = @image.attributes # observations_ids are not in here
    new_attr["slug"] = "new_img_slug"
    new_attr[:observations] = []
    @image.update(new_attr)
    assert_equal @image.observation_ids, @image.observation_ids
  end

  test "does not restore former observation list if image was not saved not due to their emptiness" do
    new_obs = create(:observation)
    new_attr = @image.attributes # observations_ids are not in here
    new_attr["slug"] = ""
    new_attr[:observations] = [new_obs]
    @image.update(new_attr)
    assert_equal [new_obs.id], @image.observation_ids
  end

  test "excludes duplicated observations on image create" do
    new_attr = attributes_for(:image).except(:observations)
    new_attr["slug"] = "new_img_slug"
    new_attr[:observation_ids] = [@obs.id, @obs.id]
    img = Image.new
    assert_difference("Image.count", 1) do
      img.update(new_attr)
    end
    assert_empty img.errors
    assert_equal [@obs.id], img.observation_ids
  end

  test "excludes duplicated observation (existing) on image update" do
    new_attr = @image.attributes
    obs = create(:observation, card: @obs.card)
    new_attr[:observation_ids] = [@obs.id, @obs.id, obs.id]
    assert @image.update(new_attr)
    assert_empty @image.errors
    assert_equal 2, @image.observation_ids.count
  end

  test "excludes duplicated observation (new) on image update" do
    new_attr = @image.attributes
    obs = create(:observation, card: @obs.card)
    new_attr[:observation_ids] = [@obs.id, obs.id, obs.id]
    assert @image.update(new_attr)
    assert_empty @image.errors
    assert_equal 2, @image.observation_ids.count
  end

  test "does not create image with inconsistent observations (different date)" do
    obs1 = create(:observation, card: create(:card, observ_date: "2011-01-01"))
    obs2 = create(:observation, card: create(:card, observ_date: "2010-01-01"))
    new_attr = build(:image).attributes
    new_attr[:observation_ids] = [obs1.id, obs2.id]
    img = Image.new
    assert_difference("Image.count", 0) do
      img.update(new_attr)
    end
    assert_predicate img.errors, :present?
  end

  test "does not create image with inconsistent observations (different loc)" do
    obs1 = create(:observation, card: create(:card, locus: loci(:kyiv)))
    obs2 = create(:observation, card: create(:card, locus: loci(:nyc)))
    new_attr = build(:image).attributes
    img = Image.new
    new_attr[:observation_ids] = [obs1.id, obs2.id]
    assert_difference("Image.count", 0) do
      img.update(new_attr)
    end
    assert_predicate img.errors, :present?
  end

  test "does not update image with inconsistent observations" do
    obs1 = create(:observation, card: create(:card, observ_date: "2011-01-01"))
    obs2 = create(:observation, card: create(:card, observ_date: "2010-01-01"))
    new_attr = @image.attributes
    new_attr[:observation_ids] = [obs1.id, obs2.id]
    assert_not @image.update(new_attr)
    assert_predicate @image.errors, :present?
  end

  test "preserves changed values if image failed to update with inconsistent observations" do
    obs1 = create(:observation, card: create(:card, observ_date: "2011-01-01"))
    obs2 = create(:observation, card: create(:card, observ_date: "2010-01-01"))
    new_attr = @image.attributes
    new_attr[:slug] = "newslug"
    new_attr[:observation_ids] = [obs1.id, obs2.id]
    assert_not @image.update(new_attr)
    assert_predicate @image.errors, :present?
    assert_equal "newslug", @image.slug
  end
end
