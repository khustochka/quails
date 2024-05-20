# frozen_string_literal: true

require "test_helper"

class MediaTest < ActiveSupport::TestCase
  test ".really_multiple_species_ids returns ids of media actually having multiple species" do
    sp1 = taxa(:saxola)
    sp2 = taxa(:jyntor)
    card = create(:card, observ_date: "2008-07-01")
    obs1 = create(:observation, taxon: sp1, card: card)
    obs2 = create(:observation, taxon: sp2, card: card)
    img1 = create(:image, observations: [obs1, obs2])
    Image.where(id: img1.id).update_all(multi_species: false)

    img2 = create(:image, observations: [obs2])
    Image.where(id: img2.id).update_all(multi_species: true)

    result = Media.really_multiple_species_ids

    assert img1.id.in?(result)
    assert_not img2.id.in?(result)
  end
end
