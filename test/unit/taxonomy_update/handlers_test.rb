# frozen_string_literal: true

require "test_helper"
require_relative "taxonomy_csv_helper"

class Quails::TaxonomyUpdate::HandlersTest < ActiveSupport::TestCase
  include TaxonomyCsvHelper

  setup do
    @rows = current_ebird_rows
    give_passan_a_taxon
    @hirrus = species(:hirrus)
  end

  # == rename

  test "rename sets new names, synonym and review flag" do
    @rows["barswa"].merge!("sci_name" => "Hirundo novus", "primary_com_name" => "New Swallow")
    @hirrus.update!(authority: "Linnaeus, 1758")

    apply(rename("barswa", name_sci: { "old" => "Hirundo rustica", "new" => "Hirundo novus" },
      name_en: { "old" => "Barn Swallow", "new" => "New Swallow", "accept" => true }))

    @hirrus.reload
    assert_equal ["Hirundo novus", "New Swallow", nil, true], [@hirrus.name_sci, @hirrus.name_en, @hirrus.authority, @hirrus.needs_review]
    assert_equal @hirrus, UrlSynonym.find_by!(name_sci: "Hirundo rustica").species
  end

  test "rejected English rename keeps my name and marks it overwritten" do
    @rows["barswa"]["primary_com_name"] = "New Swallow"

    apply(rename("barswa", name_en: { "old" => "Barn Swallow", "new" => "New Swallow", "accept" => false }))

    @hirrus.reload
    assert_equal "Barn Swallow", @hirrus.name_en
    assert @hirrus.name_en_overwritten
  end

  # == split

  test "split keeps the survivor record without observations or image and creates the observed daughter" do
    obs = observe(taxa(:hirrus))
    create(:image, observations: [obs])
    @hirrus.update_image!
    split_barn_swallow

    apply(split(survivor: "barswa9", observations: { "all" => "barswa5" }))

    @hirrus.reload
    new_species = Species.find_by!(name_sci: "Hirundo erythrogaster")
    assert_equal ["Hirundo rustica", "barswa9"], [@hirrus.name_sci, @hirrus.name_en]
    assert_equal "barswa9", @hirrus.high_level_taxon.ebird_code
    assert_nil @hirrus.image
    assert_equal new_species, obs.reload.species
    assert_equal obs.images.first, new_species.image
    assert SpeciesSplit.exists?(superspecies: @hirrus, subspecies: new_species)
    assert_nil UrlSynonym.find_by(name_sci: "Hirundo rustica")
    assert_nil taxa(:hirrus).reload.species_id
  end

  test "split renames the survivor when it is the observed daughter" do
    obs = observe(taxa(:hirrus))
    split_barn_swallow

    apply(split(survivor: "barswa5", observations: { "all" => "barswa5" }))

    @hirrus.reload
    assert_equal "Hirundo erythrogaster", @hirrus.name_sci
    assert_equal @hirrus, obs.reload.species
    assert_equal "split", UrlSynonym.find_by!(name_sci: "Hirundo rustica").reason
    assert_not Species.exists?(name_sci: "Hirundo rustica")
  end

  test "split keeps an English name I chose" do
    @hirrus.update!(name_en_overwritten: true)
    split_barn_swallow

    apply(split(survivor: "barswa9"))

    assert_equal "Barn Swallow", @hirrus.reload.name_en
  end

  test "split assigns observations by the deepest matching locus, then default" do
    in_brovary = observe(taxa(:hirrus), :brovary)
    in_kyiv = observe(taxa(:hirrus), :kyiv)
    in_nyc = observe(taxa(:hirrus), :nyc)
    split_barn_swallow

    apply(split(survivor: "barswa9",
      observations: { "by_locus" => { "ukraine" => "barswa9", "brovary" => "barswa5" }, "default" => "barswa5" }))

    assert_equal "barswa5", in_brovary.reload.taxon.ebird_code
    assert_equal "barswa9", in_kyiv.reload.taxon.ebird_code
    assert_equal "barswa5", in_nyc.reload.taxon.ebird_code
  end

  test "split refuses observations that match no locus rule and no default" do
    observe(taxa(:hirrus), :nyc)
    split_barn_swallow

    error = assert_raises(Quails::TaxonomyUpdate::Applier::Error) do
      apply(split(survivor: "barswa9", observations: { "by_locus" => { "ukraine" => "barswa5" } }))
    end
    assert_match "match no locus rule", error.message
  end

  test "split refuses observations left on a former species without a rule" do
    observe(taxa(:hirrus))
    split_barn_swallow

    assert_raises(Quails::TaxonomyUpdate::Applier::Error) { apply(split(survivor: "barswa9")) }
  end

  test "split moves local species to the chosen daughter" do
    local = LocalSpecies.create!(locus: loci(:usa), species: @hirrus)
    split_barn_swallow

    apply(split(survivor: "barswa9", local_species: { "usa" => "barswa5" }))

    assert_equal "Hirundo erythrogaster", local.reload.species.name_sci
  end

  # == lump

  test "lump merges my species into the survivor" do
    obs = observe(taxa(:hirrus))
    local = LocalSpecies.create!(locus: loci(:usa), species: @hirrus)
    @rows["barswa"].merge!("category" => "issf", "sparse_report_as" => "houspa")

    apply("type" => "lump", "status" => "ok", "into" => "houspa", "species" => ["Hirundo rustica"],
      "survivor" => "Passer domesticus")

    pasdom = species(:pasdom)
    assert_not Species.exists?(@hirrus.id)
    assert_equal pasdom, obs.reload.species
    assert_equal pasdom, local.reload.species
    assert_equal ["lump", pasdom], UrlSynonym.find_by!(name_sci: "Hirundo rustica").then { |s| [s.reason, s.species] }
  end

  # == code change

  test "code change moves observations and relinks the species" do
    ebird_taxa(:hirrus).update!(taxon_concept_id: "avibase-AAAA")
    obs = observe(taxa(:hirrus))
    @rows.delete("barswa")
    @rows["barswa5"]["sparse_report_as"] = "barswa2"
    @rows["barswa2"] = ebird_row("barswa2", "species", "Hirundo rustica", concept: "AAAA")

    apply("type" => "code_change", "status" => "ok", "code" => "barswa", "new_code" => "barswa2", "species" => "Hirundo rustica")

    assert_equal "barswa2", @hirrus.reload.high_level_taxon.ebird_code
    assert_equal ["barswa2", @hirrus], obs.reload.then { |o| [o.taxon.ebird_code, o.species] }
    assert_nil Taxon.find_by(ebird_code: "barswa")
  end

  test "observations moved to a new subspecies count for its species" do
    obs = observe(taxa(:gargla_eurasian))
    @rows.delete("eurjay2")
    @rows["eurjay9"] = ebird_row("eurjay9", "issf", "Garrulus glandarius novus", parent: "eurjay1")

    apply("type" => "code_change", "status" => "ok", "code" => "eurjay2", "new_code" => "eurjay9", "taxon" => "x")

    assert_equal species(:gargla), obs.reload.species
  end

  private

  def apply(*entries)
    run_update(@rows, entries: entries)
  end

  def observe(taxon, locus = :brovary)
    create(:observation, taxon: taxon, card: create(:card, locus_id: loci(locus).id))
  end

  def rename(code, **changes)
    { "type" => "rename", "status" => "ok", "code" => code, "species" => "Hirundo rustica" }.merge(changes.stringify_keys)
  end

  # barswa becomes a slash between barswa9 (Hirundo rustica) and the former issf barswa5.
  def split_barn_swallow
    @rows["barswa"].merge!("category" => "slash", "sci_name" => "Hirundo rustica/erythrogaster")
    @rows["barswa5"].merge!("category" => "species", "sci_name" => "Hirundo erythrogaster", "sparse_report_as" => nil,
      "family" => "Hirundinidae (Swallows)", "order1" => "Passeriformes")
    @rows["barswa9"] = ebird_row("barswa9", "species", "Hirundo rustica").merge(
      "family" => "Hirundinidae (Swallows)", "order1" => "Passeriformes"
    )
  end

  def split(**attrs)
    { "type" => "split", "status" => "ok", "code" => "barswa", "species" => "Hirundo rustica" }.merge(attrs.stringify_keys)
  end
end
