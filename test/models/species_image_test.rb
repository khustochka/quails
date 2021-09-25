# frozen_string_literal: true

require "test_helper"

class SpeciesImageTest < ActiveSupport::TestCase
  test "first species image should be attached to it automatically" do
    img = create(:image)
    assert_equal [img.id], img.species.map {|sp| sp.image.id}
  end

  test "adding another species image should not overwrite existing one" do
    img = create(:image)
    img2 = create(:image)
    assert_equal [img.id], img.species.map {|sp| sp.image.id}
  end

  test "removing the only species image should clear image_id" do
    obs = create(:observation)
    sp = obs.species
    img_id = obs.images.create(attributes_for(:image)).id

    # Have to find it to clear association cache
    img = Image.find(img_id)
    img.destroy
    sp.reload
    assert_nil sp.image
  end

  test "removing the active species image links another one to the species" do
    img = create(:image)
    img2 = create(:image)
    sps = img.species.first
    img.destroy
    sps.reload
    assert_equal img2.id, sps.image.id
  end

  test "species images should not be duplicated (if multi-species)" do
    tx1 = taxa(:saxola)
    tx2 = taxa(:jyntor)
    card = create(:card, observ_date: "2008-07-01")
    obs1 = create(:observation, taxon: tx1, card: card)
    obs2 = create(:observation, taxon: tx2, card: card)
    img = create(:image, slug: "picture-of-the-shrike-and-the-wryneck", observations: [obs1, obs2])

    assert_equal 1, tx1.species.ordered_images.to_a.size
  end

  # Relinking a main species image to another species is very unlikely,
  # and association callbacks are harder, so skipping for now

  # test 'switching the only species image to another sp should clear image_id' do
  #  obs = create(:observation, species: species('larrid'))
  #  img = create(:image)
  #  sps = img.species
  #  img.update_with_observations(nil, [obs.id])
  #  assert_equal [nil], sps.map(&:reload).map(&:image_id)
  # end
  #
  # test 'switching the active species image to another sp links another one to the species' do
  #  obs = create(:observation, species_id: species('larrid').id)
  #  img = create(:image)
  #  img2 = create(:image)
  #  sps = img.species
  #  img.update_with_observations(nil, [obs.id])
  #  assert_equal [img2.id], sps.map(&:reload).map(&:image_id)
  # end
end
