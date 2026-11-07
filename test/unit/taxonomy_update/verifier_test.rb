# frozen_string_literal: true

require "test_helper"
require_relative "taxonomy_csv_helper"

class Quails::TaxonomyUpdate::VerifierTest < ActiveSupport::TestCase
  include TaxonomyCsvHelper

  setup do
    give_passan_a_taxon
    @hirrus = species(:hirrus)
  end

  test "reports a species without a species-rank taxon" do
    taxa(:hirrus).update_column(:species_id, nil)

    assert_match "Species without a species-rank taxon (1):\n    Hirundo rustica", verifier.errors.join
  end

  test "reports observations out of sync with their taxon" do
    create(:observation, taxon: taxa(:hirrus)).update_column(:species_id, species(:pasdom).id)

    assert_match "1 observations whose species differs", verifier.errors.join
  end

  test "reports images that are not from the species' observations, and photos without an image" do
    image = create(:image, observations: [create(:observation, taxon: taxa(:hirrus))])
    SpeciesImage.where(species: @hirrus).delete_all
    SpeciesImage.create!(species: species(:pasdom), image: image)

    errors = verifier.errors.join
    assert_match "Species images not from their own observations (1):\n    Passer domesticus", errors
    assert_match "Species with photos but no image (1):\n    Hirundo rustica", errors
  end

  test "warns of English names that drifted from eBird, except hyphens and my own" do
    taxa(:hirrus).update_column(:name_en, "Barn-Swallow")
    taxa(:pasdom).update_column(:name_en, "Sparrow")

    warnings = verifier.warnings.join
    assert_match "\n    Passer domesticus: House Sparrow (eBird: Sparrow)", warnings
    assert_no_match "Hirundo rustica", warnings

    species(:pasdom).update!(name_en_overwritten: true)
    assert_no_match "Passer domesticus", verifier.warnings.join
  end

  test "lists texts linking to a split species whose observations went to another daughter" do
    @hirrus.update!(code: "hirrus")
    create(:post, post_core: create(:post_core, slug: "swallows"), lang: "en", body: "{{Swallow|hirrus}} and {{Hirundo_rustica|en}}")
    moved = { "type" => "split", "status" => "ok", "species" => "Hirundo rustica", "survivor" => "barswa9" }

    review = verifier(moved.merge("observations" => { "all" => "barswa5" })).review.join
    assert_match "Texts linking to a split species (1):\n    post swallows (en): Hirundo rustica", review

    assert_no_match "Texts", verifier(moved.merge("observations" => { "all" => "barswa9" })).review.join
  end

  private

  def verifier(*entries)
    Quails::TaxonomyUpdate::Verifier.new(manifest: Quails::TaxonomyUpdate::Manifest.new("entries" => entries))
  end
end
