require 'test_helper'

class ObservationTest < ActiveSupport::TestCase
  setup do
    @observation = create(:observation)
  end

  test 'do not destroy observation if having associated images' do
    img = create(:image, observations: [@observation])
    assert_raise(ActiveRecord::DeleteRestrictionError) { @observation.destroy }
    assert @observation.reload
    assert_equal [img], @observation.images
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

end
