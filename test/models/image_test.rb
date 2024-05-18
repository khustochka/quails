# frozen_string_literal: true

require "test_helper"

class ImageTest < ActiveSupport::TestCase
  setup do
  end

  test "image factory is valid" do
    create(:image)
  end

  test "set multi-species flag on save" do
    sp1 = taxa(:saxola)
    sp2 = taxa(:jyntor)
    card = create(:card, observ_date: "2008-07-01")
    obs1 = create(:observation, taxon: sp1, card: card)
    obs2 = create(:observation, taxon: sp2, card: card)
    img = build(:image, slug: "picture-of-the-shrike-and-the-wryneck", observations: [obs1, obs2])
    img.save
    assert_predicate img, :multi_species?
  end

  test "prev and next image by species should be correct for different days" do
    o1 = create(:observation, card: create(:card, observ_date: "2013-01-01"))
    o2 = create(:observation, card: create(:card, observ_date: "2013-02-01"))
    o3 = create(:observation, card: create(:card, observ_date: "2013-03-01"))
    s = o1.species
    im1 = create(:image, observations: [o1])
    im2 = create(:image, observations: [o2])
    im3 = create(:image, observations: [o3])
    assert_equal im1, im2.prev_by_species(s)
    assert_equal im3, im2.next_by_species(s)
  end

  test "prev and next image by species should be correct for the same day" do
    o = create(:observation)
    s = o.species
    im1 = create(:image, observations: [o])
    im2 = create(:image, observations: [o])
    im3 = create(:image, observations: [o])
    assert_equal im1, im2.prev_by_species(s)
    assert_equal im3, im2.next_by_species(s)
  end

  test "prev and next image by species should be correct if even created_at is the same" do
    o = create(:observation)
    s = o.species
    tm = Time.current
    im1 = create(:image, observations: [o], created_at: tm)
    im2 = create(:image, observations: [o], created_at: tm)
    assert_equal im1, im2.prev_by_species(s)
    assert_equal im2, im1.next_by_species(s)
  end

  test "prev and next image by species should be correct for reversed created_at" do
    o1 = create(:observation, card: create(:card, observ_date: "2013-01-01"))
    o2 = create(:observation, card: create(:card, observ_date: "2013-02-01"))
    o3 = create(:observation, card: create(:card, observ_date: "2013-03-01"))
    s = o1.species
    im3 = create(:image, observations: [o3])
    im2 = create(:image, observations: [o2])
    im1 = create(:image, observations: [o1])
    assert_equal im1, im2.prev_by_species(s)
    assert_equal im3, im2.next_by_species(s)
  end

  test "prevent duplication of multi-species image in prev next function" do
    tx1 = taxa(:saxola)
    tx2 = taxa(:jyntor)
    sp1 = tx1.species
    sp2 = tx2.species
    card = create(:card, observ_date: "2008-07-01")
    obs1 = create(:observation, taxon: tx1, card: card)
    obs2 = create(:observation, taxon: tx2, card: card)
    img = create(:image, slug: "picture-of-the-shrike-and-the-wryneck", observations: [obs1, obs2])
    assert_nil img.prev_by_species(sp1)
    assert_nil img.next_by_species(sp1)
  end

  test "image public locus should not be private" do
    brvr = loci(:brovary)
    loc = create(:locus, parent_id: brvr.id, private_loc: true)
    card = create(:card, locus: loc)
    obs1 = create(:observation, card: card)
    img = create(:image, observations: [obs1])
    assert_equal brvr, img.public_locus
  end
end
