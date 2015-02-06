require 'test_helper'

class ObservationTest < ActiveSupport::TestCase
  setup do
    @observation = create(:observation)
  end

  test 'do not destroy observation if having associated images' do
    img = create(:image, observations: [@observation])
    assert_raise(ActiveRecord::DeleteRestrictionError) { @observation.destroy }
    assert @observation.reload
    assert_equal [img], @observation.images.to_a
  end

  test 'updating observation touches card' do
    before = @observation.card.updated_at
    @observation.update_attribute(:species_id, seed('paratr').id)
    after = @observation.card.updated_at
    assert after > before
  end

  test "locus filter should filter by observations patch too" do
    card = create(:card, locus_id: seed(:kiev_obl).id)
    obs = create(:observation, card_id: card.id, patch_id: seed(:brovary).id)
    assert_includes Observation.filter(locus: seed(:brovary).id), obs
  end

  test "locus filter should filter by observations patch too (many locs)" do
    card = create(:card, locus_id: seed(:kiev_obl).id)
    obs = create(:observation, card_id: card.id, patch_id: seed(:brovary).id)
    assert_includes Observation.filter(locus: [seed(:brovary).id, seed(:geologorozvidka).id]), obs
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

end
