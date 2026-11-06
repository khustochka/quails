# frozen_string_literal: true

require "test_helper"

class SpeciesTest < ActiveSupport::TestCase
  test "do not destroy taxon if it has associated observations" do
    hirrus = taxa(:hirrus)
    observation = create(:observation, taxon: hirrus)
    assert_raise(ActiveRecord::DeleteRestrictionError) { hirrus.destroy }
    assert observation.reload
    assert_equal hirrus, observation.taxon
  end
  test "changing taxon species updates its observations" do
    hirrus = taxa(:hirrus)
    observation = create(:observation, taxon: hirrus)
    new_species = species(:pasdom)

    hirrus.update!(species: new_species)

    assert_equal new_species.id, observation.reload.species_id
  end

  test "detaching species clears species on observations of taxon and its children" do
    gargla = taxa(:gargla)
    obs_species = create(:observation, taxon: gargla)
    obs_issf = create(:observation, taxon: taxa(:gargla_eurasian))

    gargla.detach_species

    assert_nil obs_species.reload.species_id
    assert_nil obs_issf.reload.species_id
  end
end
