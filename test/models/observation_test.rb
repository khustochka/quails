# frozen_string_literal: true

require "test_helper"

class ObservationTest < ActiveSupport::TestCase
  setup do
    @observation = create(:observation)
  end

  test "do not destroy observation if having associated images" do
    img = create(:image, observations: [@observation])
    assert_raise(ActiveRecord::DeleteRestrictionError) { @observation.destroy }
    assert @observation.reload
    assert_equal [img], @observation.images.to_a
  end

  test "do not destroy observation if having associated videos" do
    video = create(:video, observations: [@observation])
    assert_raise(ActiveRecord::DeleteRestrictionError) { @observation.destroy }
    assert @observation.reload
    assert_equal [video], @observation.videos.to_a
  end

  test "species_id is set on create" do
    assert_equal @observation.taxon.species_id, @observation.species_id
  end

  test "species_id updates when taxon changes" do
    new_taxon = taxa(:hirrus)
    @observation.update!(taxon: new_taxon)
    assert_equal new_taxon.species_id, @observation.reload.species_id
  end

  test "species_id is nil for taxon without species" do
    taxon = taxa(:pasdom)
    taxon.update_column(:species_id, nil)
    obs = create(:observation, taxon: taxon)
    assert_nil obs.species_id
  end

  test "updating observation touches card" do
    before = @observation.card.updated_at
    @observation.update_attribute(:taxon_id, taxa("hirrus").id)
    after = @observation.card.updated_at
    assert_operator after, :>, before
  end

  test "the bug when images were not correctly preloaded when there were 2 observations with images in different cards" do
    img1 = create(:image)
    img2 = create(:image)
    cards = [img1.card, img2.card]
    obs_with_images = Observation.where(card_id: cards).preload(:images)
    img_slugs = obs_with_images.map(&:images).flatten.map(&:slug)
    [img1, img2].each do |img|
      assert_includes img_slugs, img.slug
    end
  end

  test "observation can be attached to any translation's core" do
    core = create(:post_core)
    uk_post = create(:post, post_core: core, lang: "uk")
    create(:post, post_core: core, lang: "en")
    observation = build(:observation, post_core: core)
    assert_predicate observation, :valid?
    assert_equal uk_post.post_core_id, observation.post_core_id
  end
end
