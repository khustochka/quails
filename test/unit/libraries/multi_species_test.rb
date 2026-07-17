# frozen_string_literal: true

require "test_helper"

class MultiSpeciesTest < ActiveSupport::TestCase
  setup do
    card = create(:card, observ_date: "2008-07-01")
    @obs1 = create(:observation, taxon: taxa(:saxola), card: card)
    @obs2 = create(:observation, taxon: taxa(:jyntor), card: card)
  end

  test "sets the flag for media linked to several species" do
    image = create(:image, observations: [@obs1, @obs2])
    Image.where(id: image.id).update_all(multi_species: false)

    Quails::MultiSpecies.fix_all

    assert_predicate image.reload, :multi_species?
  end

  test "clears the flag for media linked to a single species" do
    image = create(:image, observations: [@obs1])
    Image.where(id: image.id).update_all(multi_species: true)

    Quails::MultiSpecies.fix_all

    assert_not_predicate image.reload, :multi_species?
  end

  test "fixes all media at once" do
    multi = create(:image, observations: [@obs1, @obs2])
    single = create(:image, observations: [@obs2])
    Image.where(id: [multi.id, single.id]).update_all(multi_species: false)

    Quails::MultiSpecies.fix_all

    assert_predicate multi.reload, :multi_species?
    assert_not_predicate single.reload, :multi_species?
  end

  test "leaves already correct flags untouched" do
    multi = create(:image, observations: [@obs1, @obs2])
    single = create(:image, observations: [@obs2])

    Quails::MultiSpecies.fix_all

    assert_predicate multi.reload, :multi_species?
    assert_not_predicate single.reload, :multi_species?
  end
end
