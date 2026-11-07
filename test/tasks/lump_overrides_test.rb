# frozen_string_literal: true

require "test_helper"
require "rake"
require_relative "../unit/taxonomy_update/taxonomy_csv_helper"

class LumpOverridesTaskTest < ActiveSupport::TestCase
  include TaxonomyCsvHelper

  setup do
    Rails.application.load_tasks if Rake::Task.tasks.none? { |t| t.name == "taxonomy:lump_overrides" }
    Rake::Task["taxonomy:lump_overrides"].reenable

    @motfla = Species.create!(name_sci: "Motacilla flava", name_en: "Western Yellow Wagtail", order: "Passeriformes",
      family: "Motacillidae", index_num: 14899)
    parent = Taxon.create!(name_sci: "Motacilla flava", name_en: "Western Yellow Wagtail", ebird_code: "eaywag1", category: "species", index_num: 14899,
      species: @motfla)
    ebird_parent = EBirdTaxon.create!(name_sci: "Motacilla flava", name_en: "Western Yellow Wagtail", ebird_code: "eaywag1",
      category: "species", ebird_version: 2016, index_num: 14899, taxon: parent)
    ebird_taxa(:motfel).update!(parent: ebird_parent)
    give_passan_a_taxon
    # The task checks Verifier#errors, which wants index_num to be 1..count.
    [Taxon, Species].each do |model|
      model.order(:index_num, :id).each.with_index(1) { |rec, idx| rec.update_column(:index_num, idx) }
    end
  end

  test "lumps an override into its eBird species and leaves a redirect" do
    obs = create(:observation, taxon: taxa(:motfel))

    assert_output(/merged Motacilla feldegg into Motacilla flava/) { Rake::Task["taxonomy:lump_overrides"].invoke }

    motfel = taxa(:motfel).reload
    assert_equal ["Motacilla flava feldegg", "issf", "eaywag1", @motfla],
      [motfel.name_sci, motfel.category, motfel.parent.ebird_code, motfel.species]
    assert_equal @motfla, obs.reload.species
    assert_not Species.exists?(name_sci: "Motacilla feldegg")
    assert_equal @motfla, UrlSynonym.find_by!(name_sci: "Motacilla feldegg").species
  end
end
