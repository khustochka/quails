# frozen_string_literal: true

require "test_helper"
require_relative "taxonomy_csv_helper"

class Quails::TaxonomyUpdate::ApplierTest < ActiveSupport::TestCase
  include TaxonomyCsvHelper

  setup do
    @rows = current_ebird_rows
    give_passan_a_taxon
  end

  test "applies an unchanged taxonomy" do
    apply

    assert_equal [2026], EBirdTaxon.distinct.pluck(:ebird_version)
    assert_equal (1..Taxon.count).to_a, Taxon.order(:index_num).pluck(:index_num)
    assert_equal (1..Species.count).to_a, Species.order(:index_num).pluck(:index_num)
  end

  test "dry run rolls everything back" do
    @rows["barswa"]["primary_com_name"] = "Changed"

    apply(dry_run: true)

    assert_equal "Barn Swallow", taxa(:hirrus).reload.name_en
    assert_not_includes EBirdTaxon.distinct.pluck(:ebird_version), 2026
  end

  test "re-syncs taxa names and order, then species order" do
    barswa = @rows.delete("barswa")
    @rows = { "barswa" => barswa.merge("primary_com_name" => "Swallow") }.merge(@rows)

    apply

    assert_equal "Swallow", taxa(:hirrus).reload.name_en
    assert_equal 1, taxa(:hirrus).index_num
    assert_equal 1, species(:hirrus).reload.index_num
  end

  test "overrides keep their names and rank" do
    @rows["weywag6"]["sci_name"] = "Motacilla flava superbus"

    apply

    motfel = taxa(:motfel).reload
    assert_equal "Motacilla feldegg", motfel.name_sci
    assert_equal "species", motfel.category
  end

  test "imports new eBird taxa with parents and drops unused removed ones" do
    @rows["barswa9"] = ebird_row("barswa9", "issf", "Hirundo rustica novus", parent: "barswa")
    @rows.delete("tinamu1")

    apply

    assert_equal "barswa", EBirdTaxon.find_by!(ebird_code: "barswa9").parent.ebird_code
    assert_nil EBirdTaxon.find_by(ebird_code: "tinamu1")
  end

  test "local taxa go after all eBird taxa" do
    apply

    assert_equal Taxon.count, taxa(:unreported_bird_sp).reload.index_num
  end

  test "refuses to drop a removed taxon with observations, rolling back" do
    create(:observation, taxon: taxa(:gargla_eurasian))
    @rows.delete("eurjay2")

    error = assert_raises(Quails::TaxonomyUpdate::Applier::Error) { apply }

    assert_match "eurjay2", error.message
    assert_not_includes EBirdTaxon.distinct.pluck(:ebird_version), 2026
  end

  test "refuses a manifest with draft entries" do
    entries = [{ "type" => "rename", "status" => "draft", "code" => "barswa" }]

    error = assert_raises(Quails::TaxonomyUpdate::Applier::Error) { apply(entries: entries) }

    assert_match "barswa: still draft", error.message
  end

  test "refuses ok entries without a handler" do
    entries = [{ "type" => "ambiguous", "status" => "ok", "code" => "barswa" }]

    assert_raises(Quails::TaxonomyUpdate::Applier::Error) { apply(entries: entries) }
  end

  private

  def apply(entries: [], dry_run: false)
    run_update(@rows, entries: entries, dry_run: dry_run)
  end
end
